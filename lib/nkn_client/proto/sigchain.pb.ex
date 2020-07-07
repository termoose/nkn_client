defmodule NknClient.Proto.SigChain.SigAlgo do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :SIGNATURE | :VRF

  field :SIGNATURE, 0
  field :VRF, 1
end

defmodule NknClient.Proto.SigChain.SigChainElem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: binary,
          next_pubkey: binary,
          mining: boolean,
          signature: binary,
          sig_algo: NknClient.Proto.SigChain.SigAlgo.t(),
          vrf: binary,
          proof: binary
        }
  defstruct [:id, :next_pubkey, :mining, :signature, :sig_algo, :vrf, :proof]

  field :id, 1, type: :bytes
  field :next_pubkey, 2, type: :bytes
  field :mining, 3, type: :bool
  field :signature, 4, type: :bytes
  field :sig_algo, 5, type: NknClient.Proto.SigChain.SigAlgo, enum: true
  field :vrf, 6, type: :bytes
  field :proof, 7, type: :bytes
end

defmodule NknClient.Proto.SigChain.SigChain do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          nonce: non_neg_integer,
          data_size: non_neg_integer,
          block_hash: binary,
          src_id: binary,
          src_pubkey: binary,
          dest_id: binary,
          dest_pubkey: binary,
          elems: [NknClient.Proto.SigChain.SigChainElem.t()]
        }
  defstruct [
    :nonce,
    :data_size,
    :block_hash,
    :src_id,
    :src_pubkey,
    :dest_id,
    :dest_pubkey,
    :elems
  ]

  field :nonce, 1, type: :uint32
  field :data_size, 2, type: :uint32
  field :block_hash, 3, type: :bytes
  field :src_id, 4, type: :bytes
  field :src_pubkey, 5, type: :bytes
  field :dest_id, 6, type: :bytes
  field :dest_pubkey, 7, type: :bytes
  field :elems, 8, repeated: true, type: NknClient.Proto.SigChain.SigChainElem
end
