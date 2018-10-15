defmodule NknClient.Proto do
  alias NknClient.Proto.Messages
  alias NknClient.Proto.Payloads

  def text(dest, data) do
    Payloads.text(data)
    |> Messages.outbound(dest)
  end

  def binary(dest, data) do
    Payloads.binary(data)
    |> Messages.outbound(dest)
  end
end
