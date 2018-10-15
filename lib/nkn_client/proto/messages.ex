defmodule NknClient.Proto.Messages do
  use Protobuf, from: Path.expand("messages.proto", __DIR__)
  alias NknClient.Proto.Messages.OutboundMessage

  @holding_secs 5

#  def outbound(payload, dests) when is_list(dests) do
#    OutboundMessage.new(dests: dests, payload: payload,
#                        max_holding_seconds: @holding_secs)
#    |> OutboundMessage.encode
#  end

  def outbound(payload, dest) do
    OutboundMessage.new(dest: dest, payload: payload,
                        max_holding_seconds: @holding_secs)
    |> OutboundMessage.encode
  end
end
