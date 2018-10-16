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
    # If this pattern match fails we crash the entire
    # WS supervisior tree and reconnects
    %{"Error" => 0} = frame |> Poison.decode!

    # If we get this far we send this message to our
    # message sink's queue
    NknClient.WS.MessageSink.handle(msg)

    {:ok, state}
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
