defmodule NknClient.Proto.Messages do
  use Protobuf, from: Path.expand("messages.proto", __DIR__)
  alias NknClient.Proto.Messages.OutboundMessage
  alias NknClient.Proto.Messages.InboundMessage
	alias NknClient.Proto.Messages.ClientMessage
  alias NknClient.Proto.Payloads.Payload
  alias NknClient.Proto.Payloads.Message
  import Logger

  @holding_secs 3600

  def outbound(payload, dests) when is_list(dests) do
    OutboundMessage.new(dests: dests, payload: payload,
                        max_holding_seconds: @holding_secs)
    |> OutboundMessage.encode
  end

  def outbound(payload, dest) do
    OutboundMessage.new(dest: dest, payload: payload,
                        max_holding_seconds: @holding_secs)
    |> OutboundMessage.encode
  end

  def inbound(msg) do
		# FIXME: make this into a |> pipeline
		client_message = ClientMessage.decode(msg)
    decoded_msg = InboundMessage.decode(client_message.message)
    message = Message.decode(decoded_msg.payload)

    case message.encrypted do
      true ->
        pub_key = NknClient.Proto.Payloads.get_pubkey(decoded_msg.src)
				decrypted = NknClient.Crypto.Keys.decrypt(message.payload, pub_key, message.nonce)
				dec_payload = NknClient.Proto.Payloads.Payload.decode(decrypted)

        %{"data" => decode_payload(dec_payload),
          "from" => decoded_msg.src}
      false ->
				payload = Payload.decode(message.payload)

        %{"data" => decode_payload(payload),
          "from" => decoded_msg.src}
    end
  end

  def decode_payload(%Payload{type: :TEXT, data: data} = payload) do
    NknClient.Proto.Payloads.TextData.decode(data).text
  end

  def decode_payload(%Payload{data: data} = payload) do
		data
  end

  # We don't decode anything but text
  def decode_payload(%Payload{data: data} = payload), do: data
end
