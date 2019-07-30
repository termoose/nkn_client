defmodule NknClient.Proto.SigChain do
  use Protobuf, from: Path.expand("sigchain.proto", __DIR__)
  alias NknClient.Proto.SigChain.SigChainElem
  alias NknClient.Proto.SigChain.SigChain
  import Logger

  def sigchain_elem(public_key) do
    SigChainElem.new(next_pubkey: public_key)
    |> SigChainElem.encode
  end

  def sigchain(payload_length) do
    SigChain.new(
      nonce: random_integer(),
      data_size: payload_length,
      block_hash: NknClient.Crypto.SigChain.get_hash()
    )
  end

  def random_integer do
    <<n :: 32>> = :crypto.strong_rand_bytes(4)
    n
  end
end
