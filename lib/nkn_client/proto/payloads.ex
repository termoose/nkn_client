defmodule NknClient.Proto.Payloads do
  use Protobuf, from: Path.expand("payloads.proto", __DIR__)
  alias NknClient.Proto.Payloads.Payload

  def binary(data) do
    Payload.new(type: :BINARY, data: data)
    |> Payload.encode
  end

  def text(data) do
    Payload.new(type: :TEXT, data: data)
    |> Payload.encode
  end
end

