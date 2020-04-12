defmodule NknClient.Proto.Payloads do
  use Protobuf, from: Path.expand("payloads.proto", __DIR__)
  alias NknClient.Proto.Payloads.Message
  alias NknClient.Proto.Payloads.Payload
  alias NknClient.Proto.Payloads.TextData
  alias NknClient.Common.Util
  alias NknClient.Proto.Types

  @message_id_size 8

  # TODO: reply_to_id, message_id
  def binary(data) do
    pb_encode_payload(data, :BINARY, _reply_to_id = nil, _message_id = nil)
  end

  # TODO: reply_to_id, message_id
  def text(data) do
    TextData.new(text: data)
    |> TextData.encode()
    |> pb_encode_payload(:TEXT, _reply_to_id = nil, _message_id = nil)
  end

  @spec message(pb_encode_payload :: binary(), Types.destination(), binary()) :: [
          pb_encode_message :: binary()
        ]
  def message(payload, dest, encrypt?)

  def message(_payload, dests, _encrypt?)
      when is_list(dests) and 0 == length(dests) do
    raise "Proto: dests is an empty list"
  end

  def message(payload, dest, encrypt?) do
    dest = process_dest(dest)
    create_payload_message(payload, encrypt?, dest)
  end

  ## private

  @spec process_dest(Types.destination()) :: Types.destination()
  defp process_dest(dests) when is_list(dests) do
    dests |> Enum.map(&process_dest/1)
  end

  defp process_dest(dest) when is_binary(dest) do
    pubic_key = Util.addr_to_pubkey(dest)

    if String.length(pubic_key) < :enacl.box_PUBLICKEYBYTES() do
      # TODO: registered name
      raise "registered name has not been implemented"
    else
      dest
    end
  end

  defp create_payload_message(payload, encrypt?, _dest) do
    if encrypt? do
      # TODO: encrypt payload
      raise "encrypt payload has not been implemented"
    else
      [pb_encode_message(payload, false)]
    end
  end

  defp unixtime, do: System.system_time(:second)

  ## pb

  defp pb_encode_payload(data, type, reply_to_id, message_id) do
    if reply_to_id do
      [reply_to_id: reply_to_id]
    else
      [message_id: message_id || :enacl.randombytes(@message_id_size)]
    end
    |> Keyword.merge(type: type, data: data)
    |> Payload.new()
    |> Payload.encode()
  end

  defp pb_encode_message(payload, encrypt?, nonce \\ nil, encrypted_key \\ nil) do
    [nonce: nonce, encrypted_key: encrypted_key]
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Keyword.merge(payload: payload, encrypted: encrypt?)
    |> Message.new()
    |> Message.encode()
  end
end
