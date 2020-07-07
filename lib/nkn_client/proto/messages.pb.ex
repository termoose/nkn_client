defmodule NknClient.Proto.Messages.ClientMessageType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :OUTBOUND_MESSAGE | :INBOUND_MESSAGE | :RECEIPT

  field :OUTBOUND_MESSAGE, 0
  field :INBOUND_MESSAGE, 1
  field :RECEIPT, 2
end

defmodule NknClient.Proto.Messages.CompressionType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :COMPRESSION_NONE | :COMPRESSION_ZLIB

  field :COMPRESSION_NONE, 0
  field :COMPRESSION_ZLIB, 1
end

defmodule NknClient.Proto.Messages.ClientMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message_type: NknClient.Proto.Messages.ClientMessageType.t(),
          message: binary,
          compression_type: NknClient.Proto.Messages.CompressionType.t()
        }
  defstruct [:message_type, :message, :compression_type]

  field :message_type, 1, type: NknClient.Proto.Messages.ClientMessageType, enum: true
  field :message, 2, type: :bytes
  field :compression_type, 3, type: NknClient.Proto.Messages.CompressionType, enum: true
end

defmodule NknClient.Proto.Messages.OutboundMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dest: String.t(),
          payload: binary,
          dests: [String.t()],
          max_holding_seconds: non_neg_integer,
          nonce: non_neg_integer,
          block_hash: binary,
          signatures: [binary],
          payloads: [binary]
        }
  defstruct [
    :dest,
    :payload,
    :dests,
    :max_holding_seconds,
    :nonce,
    :block_hash,
    :signatures,
    :payloads
  ]

  field :dest, 1, type: :string
  field :payload, 2, type: :bytes
  field :dests, 3, repeated: true, type: :string
  field :max_holding_seconds, 4, type: :uint32
  field :nonce, 5, type: :uint32
  field :block_hash, 6, type: :bytes
  field :signatures, 7, repeated: true, type: :bytes
  field :payloads, 8, repeated: true, type: :bytes
end

defmodule NknClient.Proto.Messages.InboundMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          src: String.t(),
          payload: binary,
          prev_signature: binary
        }
  defstruct [:src, :payload, :prev_signature]

  field :src, 1, type: :string
  field :payload, 2, type: :bytes
  field :prev_signature, 3, type: :bytes
end

defmodule NknClient.Proto.Messages.Receipt do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          prev_signature: binary,
          signature: binary
        }
  defstruct [:prev_signature, :signature]

  field :prev_signature, 1, type: :bytes
  field :signature, 2, type: :bytes
end
