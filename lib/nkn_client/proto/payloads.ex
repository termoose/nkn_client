defmodule NknClient.Proto.Payloads do
  use Protobuf, from: Path.expand("payloads.proto", __DIR__)
  alias NknClient.Proto.Payloads.Payload
  alias NknClient.Proto.Payloads.TextData

  def binary(data) do
    Payload.new(type: :BINARY, data: data)
    |> Payload.encode
  end

  def text(data) do
    TextData.new(text: data)
    |> TextData.encode
    |> create_payload
    |> Payload.encode
  end

  def gen_pid do
    
  end

  def random_bytes(length), do: 1..length |> Enum.map(fn _ -> Enum.random(0..255) end)
  defp create_payload(data), do: Payload.new(type: :TEXT, data: data)
  defp unixtime, do: System.system_time(:second)
end

