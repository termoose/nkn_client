defmodule NknClient.Proto do
  require Logger

  alias NknClient.Proto.Messages
  alias NknClient.Proto.Payloads

  def text(dest, data) do
    Payloads.text(data)
    |> Payloads.message(dest, _encrypt? = false)
    |> Messages.outbound(dest)
  end

  def binary(dest, data) do
    Payloads.binary(data)
    |> Payloads.message(dest, _encrypt? = false)
    |> Messages.outbound(dest)
  end
end
