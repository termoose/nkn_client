defmodule NknClient.Proto.Payloads do
  use Protobuf, from: Path.expand("payloads.proto", __DIR__)
  alias NknClient.Proto.Payloads.Message
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
    |> IO.inspect
    |> Payload.encode
  end

  def message(payload, false = _encrypt, dest) do
    Message.new(payload: payload, encrypted: false)
    |> IO.inspect
    |> Message.encode
  end

  def message(payload, true = _encrypt, dest) do
    Message.new(payload: payload)
    |> Message.encode
  end

  def get_pubkey([id, pubkey]) do
    pubkey
  end

  def get_pubkey([pubkey]) do
    pubkey
  end

  def get_pubkey(pubkey) do
    get_pubkey(String.split(pubkey, "."))
  end

  def random_bytes(length), do: 1..length |> Enum.map(fn _ -> Enum.random(0..255) end)
  defp create_payload(data), do: Payload.new(type: :TEXT, data: data, pid: random_bytes(8))
  defp unixtime, do: System.system_time(:second)
end

