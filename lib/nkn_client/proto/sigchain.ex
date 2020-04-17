defmodule NknClient.Proto.SigChain do
  use Protobuf, from: Path.expand("sigchain.proto", __DIR__)
  alias NknClient.Proto.SigChain.SigChainElem
  alias NknClient.Proto.SigChain.SigChain

  alias NknClient.Common.Util
  alias NknClient.Common.Serialize
  alias NknClient.Common.Hash

  def sigchain_and_signatures(payloads, dests) do
    sigchain = pb_sigchain_struct()
    signatures = calc_signatures(sigchain, payloads, dests)

    {sigchain, signatures}
  end

  ## private

  defp calc_signatures(sigchain, payloads, dests) do
    payloads =
      if length(payloads) > 1 do
        payloads
      else
        payloads |> List.first() |> List.duplicate(length(dests))
      end

    sigchain_elem = pb_sigchain_elem()

    Enum.zip(dests, payloads)
    |> Enum.map(fn {dest, payload} ->
      dest_id = dest |> Hash.sha_256_bytes()
      dest_pubkey = dest |> Util.addr_to_pubkey() |> Util.hex_to_bytes()
      data_size = byte_size(payload)

      sigchain
      |> Map.merge(%{dest_id: dest_id, dest_pubkey: dest_pubkey, data_size: data_size})
      |> serialize_sig_chain_metadata()
      |> Hash.sha_256_bytes()
      |> (fn digest -> digest <> sigchain_elem end).()
      |> Hash.sha_256_bytes()
      |> NknClient.Crypto.Keys.sign()
    end)
  end

  defp pb_sigchain_struct() do
    SigChain.new(
      nonce: Util.random_int_32(),
      block_hash: Util.hex_to_bytes(NknClient.WS.NodeInfo.get_block_hash()),
      src_id: Hash.sha_256_bytes(NknClient.Crypto.address()),
      src_pubkey: Util.hex_to_bytes(NknClient.Crypto.pub_key())
    )
  end

  defp serialize_sig_chain_metadata(sig_chain) do
    [
      Serialize.encode_uint32(sig_chain.nonce),
      Serialize.encode_uint32(sig_chain.data_size),
      Serialize.encode_bytes(sig_chain.block_hash),
      Serialize.encode_bytes(sig_chain.src_id),
      Serialize.encode_bytes(sig_chain.src_pubkey),
      Serialize.encode_bytes(sig_chain.dest_id),
      Serialize.encode_bytes(sig_chain.dest_pubkey)
    ]
    |> Enum.join("")
  end

  defp pb_sigchain_elem() do
    SigChainElem.new(next_pubkey: Util.hex_to_bytes(NknClient.WS.NodeInfo.get_public_key()))
    |> SigChainElem.encode()
  end
end
