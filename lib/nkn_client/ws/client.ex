defmodule NknClient.WS.Client do
  use WebSockex
  require Logger

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, url, name: __MODULE__)
  end

  def send_frame(msg) do
    Logger.debug("Sending: #{inspect(msg)}")
    WebSockex.send_frame(__MODULE__, msg)
  end

  # All messages from NKN nodes are :binary
  def handle_frame({:binary, frame} = msg, state) do
    frame
    |> NknClient.Proto.Messages.inbound
    |> NknClient.WS.MessageSink.handle

    {:ok, state}
  end

  # We only receive :text type from the NKN server node,
  # none of the payloads from other nodes are :text
  def handle_frame({:text, frame} = msg, state) do
    Logger.debug("Raw: #{inspect(frame)}")

    # If this JSON parsing fails we crash the entire
    # WS supervisior tree and reconnects
    json_frame = frame |> Poison.decode!

    case json_frame do
      %{"Error" => 48001} ->
        handle_wrong_node(json_frame)

      _ ->
        NknClient.WS.MessageSink.handle(msg)

    end

    {:ok, state}
  end

  def handle_wrong_node(json_frame) do
    # ... signal getaddr function to return body next time
    %{"Result" => body} = json_frame
    Logger.debug("Body: #{inspect(body)}", body);

    exit(:normal);
  end

  def terminate(reason, state) do
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
