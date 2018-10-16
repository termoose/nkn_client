defmodule NknClient.Proto.Messages do
  use Protobuf, from: Path.expand("messages.proto", __DIR__)
  alias NknClient.Proto.Messages.OutboundMessage
  alias NknClient.Proto.Messages.InboundMessage
  alias NknClient.Proto.Payloads.Payload

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
    decoded_msg = InboundMessage.decode(msg)
    payload = Payload.decode(decoded_msg.payload)

    %{"data" => decode_payload(payload),
      "from" => decoded_msg.src}
  end

  def decode_payload(%Payload{type: :TEXT, data: data} = payload) do
    NknClient.Proto.Payloads.TextData.decode(data).text
  end

  # We don't decode anything but text
  def decode_payload(%Payload{data: data} = payload), do: data
end
