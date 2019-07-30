defmodule NknClient.Proto.SigChain do
  use Protobuf, from: Path.expand("sigchain.proto", __DIR__)
  alias NknClient.Proto.SigChain.SigChainElem
  alias NknClient.Proto.SigChain.SigChain
  import Logger

  def sigchain_elem do
    SigChainElem.new(next_pubkey: NknClient.WS.NodeInfo.get_public_key())
    |> SigChainElem.encode
  end

  def sigchain(payload_length) do
    SigChain.new(
      nonce: random_integer(),
      data_size: payload_length,
      block_hash: NknClient.WS.NodeInfo.get_block_hash(),
    )
  end

  def random_integer do
    <<n :: 32>> = :crypto.strong_rand_bytes(4)
    n
  end
end
