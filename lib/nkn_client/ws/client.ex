defmodule NknClient.WS.Client do
  use WebSockex
  require Logger

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, url, name: __MODULE__)
  end

  def send_frame(msg) do
    WebSockex.send_frame(__MODULE__, msg)
  end

  # All messages from NKN nodes are :binary
  def handle_frame({:binary, frame}, state) do
    frame
    |> IO.inspect
    |> NknClient.Proto.Messages.inbound
    |> NknClient.WS.MessageSink.handle

    {:ok, state}
  end

  # We only receive :text type from the NKN server node,
  # none of the payloads from other nodes are :text
  def handle_frame({:text, frame} = msg, state) do
		# If this JSON parsing fails we crash the entire
    # WS supervisior tree and reconnect
    json_frame = frame |> Poison.decode!

    case json_frame do
      %{"Error" => 48001} ->
        handle_wrong_node(json_frame)

      %{"Action" => "updateSigChainBlockHash", "Error" => 0, "Result" => block_hash} ->
        handle_new_sigchain_hash(block_hash)

      %{"Action" => "setClient", "Error" => 0, "Result" => data} ->
        handle_set_client(data)

      _ ->
        NknClient.WS.MessageSink.handle(msg)

    end

    {:ok, state}
  end

  def handle_set_client(data) do
    %{"sigChainBlockHash" => block_hash} = data

    handle_new_sigchain_hash(block_hash)
  end

  def handle_new_sigchain_hash(block_hash) do
    NknClient.Crypto.SigChain.set(block_hash)
    #Logger.debug("SigChain: #{inspect(block_hash)}")
  end

  def handle_wrong_node(json_frame) do
    # This will crash the supervisor if there is no "Result",
    # which should never happen anyway
    %{"Result" => body} = json_frame

    Logger.error("Wrong node, changing to: #{inspect(body)}");

    # Signal RPC to return new correct node next time
    NknClient.RPC.set_address(body)

    # This will tear down the entire WS supervisor
    # since it's :one_for_all
    exit(:normal);
  end

  def terminate(reason, _state) do
    Logger.error("WS.Client terminate: #{inspect(reason)}")
    exit(:normal)
  end

  def handle_connect(conn, state) do
    Logger.info("Connected to #{state}: #{inspect(conn.host)}")
    {:ok, state}
  end

  def handle_disconnect(reason, state) do
    Logger.info("Disconnected: #{inspect(reason)}")
    {:ok, state}
  end
end
