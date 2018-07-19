defmodule NknClient.WS do
  use GenServer
  require Logger
  alias NknClient.WS.Client

  def start_link(ping_freq) do
    GenServer.start_link(__MODULE__, ping_freq, name: __MODULE__)
  end

  def init(ping_freq) do
    #send(__MODULE__, :ping)
    {:ok, ping_freq}
  end

  def send_bin(bin) do
    Client.send({:binary, bin})
  end

  def send_txt(msg) do
    Client.send({:text, msg})
  end

  def handle_info(:ping, ping_freq) do
    Client.send(:ping)
    Process.send_after(__MODULE__, :ping, 1000 * ping_freq)

    {:noreply, ping_freq}
  end
end
