defmodule NknClient.Proto.Messages do
  use Protobuf, from: Path.expand("messages.proto", __DIR__)
  alias NknClient.Proto.Messages.OutboundMessage
  alias NknClient.Proto.Messages.InboundMessage
  alias NknClient.Proto.Messages.ClientMessage
  alias NknClient.Proto.Payloads.Payload
  alias NknClient.Proto.Payloads.Message
  alias NknClient.Common.Util
  alias NknClient.Proto.Types

  require Logger

  @signature_length 64

  # in bytes. NKN node is using 4*1024*1024 as limit, we give some additional space for serialization overhead.
  @max_client_message_size 4_000_000

  @holding_secs 3600

  @spec outbound(
          pb_encode_payloads :: list(binary()),
          Types.destination(),
          max_holding_seconds :: integer()
        ) ::
          pb_encode_outbound_messages :: [binary()]
  def outbound(payloads, dest, max_holding_seconds \\ @holding_secs) do
    if length(payloads) > 1 do
      # TODO: multi payloads
      raise "multi payloads has not been implemented"
    else
      check_size(payloads, dest)
      outbound_message = create_outbound_message(dest, payloads, max_holding_seconds)

      compression_type =
        if length(payloads) > 1 do
          :COMPRESSION_ZLIB
        else
          :COMPRESSION_NONE
        end

      message =
        if compression_type == :COMPRESSION_ZLIB do
          z = :zlib.open()
          :zlib.deflateInit(z)
          compressed = :zlib.deflate(z, outbound_message)
          :zlib.close(z)

          compressed
        else
          outbound_message
        end

      ClientMessage.new(
        message_type: :OUTBOUND_MESSAGE,
        compression_type: compression_type,
        message: message
      )
      |> ClientMessage.encode()
      |> List.wrap()
    end
  end

  def inbound(msg) do
    # FIXME: make this into a |> pipeline
    client_message = ClientMessage.decode(msg)
    decoded_msg = InboundMessage.decode(client_message.message)
    message = Message.decode(decoded_msg.payload)

    message_decoded =
      case message.encrypted do
        true ->
          pub_key = Util.addr_to_pubkey(decoded_msg.src)
          decrypted = NknClient.Crypto.Keys.decrypt(message.payload, pub_key, message.nonce)
          dec_payload = NknClient.Proto.Payloads.Payload.decode(decrypted)

          %{"data" => decode_payload(dec_payload), "from" => decoded_msg.src}

        false ->
          payload = Payload.decode(message.payload)

          %{"data" => decode_payload(payload), "from" => decoded_msg.src}
      end

    Logger.debug("Inbound message: #{inspect(message_decoded)}")

    message_decoded
  end

  def decode_payload(%Payload{type: :TEXT, data: data}) do
    NknClient.Proto.Payloads.TextData.decode(data).text
  end

  def decode_payload(%Payload{data: data}) do
    data
  end

  ## private

  defp check_size(payloads, dest) when is_binary(dest) do
    check_size(payloads, [dest])
  end

  defp check_size([payload], dests) when is_list(dests) do
    size =
      dests
      |> Enum.reduce(
        byte_size(payload),
        fn d, acc ->
          acc + byte_size(d) + @signature_length
        end
      )

    if size > @max_client_message_size do
      raise "encoded message size #{size} is greater than #{@max_client_message_size} bytes"
    end
  end

  defp create_outbound_message(dest, payload, max_holding_seconds) when not is_list(dest) do
    create_outbound_message([dest], payload, max_holding_seconds)
  end

  defp create_outbound_message(dests, payloads, max_holding_seconds) do
    if length(dests) == 0 do
      raise "Message: destination list is empty"
    end

    if length(payloads) == 0 do
      raise "Message: payload list is empty"
    end

    if length(payloads) > 1 && length(payloads) != length(dests) do
      raise "Message: invalid payload array length"
    end

    {sigchain, signatures} = NknClient.Proto.SigChain.sigchain_and_signatures(payloads, dests)

    OutboundMessage.new(
      dests: dests,
      payloads: payloads,
      max_holding_seconds: max_holding_seconds,
      nonce: sigchain.nonce,
      block_hash: sigchain.block_hash,
      signatures: signatures
    )
    |> OutboundMessage.encode()
  end
end
