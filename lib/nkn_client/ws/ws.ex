defmodule NknClient.WS do
  use GenServer
  require Logger
  alias NknClient.WS.Client

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(state) do
    %{"Action" => "setClient",
      "Addr" => "#{NknClient.Crypto.public_key()}"}
    |> Poison.encode!
    |> send_txt

    {:ok, state}
  end

  def send(dest, payload) do
    %{"Action" => "sendPacket",
      "Dest" => dest,
      "Payload" => payload,
      "Signature" => ""}
    |> Poison.encode!
    |> send_txt
  end

  defp send_bin(bin) do
    Client.send({:binary, bin})
  end

  defp send_txt(msg) do
    Client.send({:text, msg})
  end
end
