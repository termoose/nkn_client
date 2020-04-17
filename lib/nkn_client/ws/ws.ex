defmodule NknClient.WS do
  use GenServer
  require Logger
  alias NknClient.WS.Client

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(state) do
    %{"Action" => "setClient", "Addr" => "#{NknClient.Crypto.address()}"}
    |> Jason.encode!()
    |> send_txt

    {:ok, state}
  end

  def send_text(dest, message) do
    NknClient.Proto.text(dest, message)
    |> Enum.each(&send_bin/1)
  end

  def send_bin(dest, message) do
    NknClient.Proto.binary(dest, message)
    |> Enum.each(&send_bin/1)
  end

  defp send_bin(bin) do
    Client.send_frame({:binary, bin})
  end

  defp send_txt(msg) do
    Client.send_frame({:text, msg})
  end
end
