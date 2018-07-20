defmodule NknClient.WS do
  use GenServer
  require Logger
  alias NknClient.WS.Client

  def start_link(ping_freq) do
    GenServer.start_link(__MODULE__, ping_freq, name: __MODULE__)
  end

  def init(ping_freq) do
    %{"Action" => "setClient",
      "Addr" => "#{NknClient.Crypto.public_key()}"}
    |> Poison.encode!
    |> send_txt

    {:ok, ping_freq}
  end

  def send(dest, payload) do
    %{"Action" => "sendPacket",
      "Dest" => dest,
      "Payload" => payload,
      "Signature" => ""}
    |> Poison.encode!
    |> send_txt
  end

  def handle_info(:ping, ping_freq) do
    Client.send(:ping)
    Process.send_after(__MODULE__, :ping, 1000 * ping_freq)

    {:noreply, ping_freq}
  end

  defp send_bin(bin) do
    Client.send({:binary, bin})
  end

  defp send_txt(msg) do
    Client.send({:text, msg})
  end
end
