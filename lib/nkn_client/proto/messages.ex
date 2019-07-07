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
		client_message = ClientMessage.decode(msg)
		Logger.debug("Msg before decode: #{inspect(client_message)}")
    decoded_msg = InboundMessage.decode(client_message.message)
		IO.inspect(decoded_msg)
    message = Message.decode(decoded_msg.payload)
		#	payload = Payload.decode(message.payload)

    #test_msg = NknClient.Proto.Payloads.Message.decode(decoded_msg)
    Logger.debug("Msg: #{inspect(message, limit: :infinity)}")

    # FIXME: figure out why we can't decrypt
    case message.encrypted do
      true ->
        pub_key = NknClient.Proto.Payloads.get_pubkey(decoded_msg.src)
        %{"data" => NknClient.Crypto.Keys.decrypt(message.payload, pub_key, message.nonce),
          "from" => decoded_msg.src}
      false ->
				payload = Payload.decode(message.payload)
        %{"data" => decode_payload(payload),
          "from" => decoded_msg.src}
    end

#    %{"data" => message,
#      "from" => decoded_msg.src}
#    %{"data" => decode_payload(payload),
#      "from" => decoded_msg.src}
  end

  def decode_payload(%Payload{type: :TEXT, data: data} = payload) do
    NknClient.Proto.Payloads.TextData.decode(data).text
  end

  def decode_payload(%Payload{data: data} = payload) do
    msg = NknClient.Proto.Payloads.Message.decode(data)

    %{payload: msg.payload,
      encrypted: msg.encrypted,
      nonce: msg.nonce}
  end

  # We don't decode anything but text
  def decode_payload(%Payload{data: data} = payload), do: data
end
