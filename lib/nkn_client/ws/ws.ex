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
    |> send_while_error(&send_bin/1)
  end

  def send_bin(dest, message) do
    NknClient.Proto.binary(dest, message)
    |> send_while_error(&send_bin/1)
  end

  defp send_bin(bin) do
    Client.send_frame({:binary, bin})
  end

  defp send_txt(msg) do
    Client.send_frame({:text, msg})
  end

  defp send_while_error(frames, func) do
    Enum.reduce_while(frames, :ok, fn frame, respond ->
      case func.(frame) do
        :ok -> {:cont, respond}
        {:error, _error_reason} = e -> {:halt, e}
      end
    end)
  end
end
