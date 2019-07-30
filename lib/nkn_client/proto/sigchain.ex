defmodule NknClient.Proto.SigChain do
  use Protobuf, from: Path.expand("sigchain.proto", __DIR__)
  alias NknClient.Proto.SigChain.SigChainElem
  import Logger

  def sigchain_elem(public_key) do
    SigChainElem.new(next_pubkey: public_key)
    |> SigChainElem.encode
  end
end
