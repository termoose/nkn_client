defmodule NknClient.Proto do
  alias NknClient.Proto.Messages
  alias NknClient.Proto.Payloads

  def text(dest, data) do
    Payloads.text(data)
    |> Payloads.message(false, dest)
    |> Messages.outbound(dest)
  end

  def binary(dest, data) do
    Payloads.binary(data)
    |> Payloads.message(false, dest)
    |> Messages.outbound(dest)
  end
end
