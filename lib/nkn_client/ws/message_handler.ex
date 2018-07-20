defmodule NknClient.WS.MessageHandler do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def ingest_txt(txt_msg) do
    Logger.debug("txt_msg: #{inspect(txt_msg)}")
  end
end
