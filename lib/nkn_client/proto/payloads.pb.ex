defmodule NknClient.Proto.Payloads.PayloadType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :BINARY | :TEXT | :ACK | :SESSION

  field :BINARY, 0
  field :TEXT, 1
  field :ACK, 2
  field :SESSION, 3
end

defmodule NknClient.Proto.Payloads.Message do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          payload: binary,
          encrypted: boolean,
          nonce: binary,
          encrypted_key: binary
        }
  defstruct [:payload, :encrypted, :nonce, :encrypted_key]

  field :payload, 1, type: :bytes
  field :encrypted, 2, type: :bool
  field :nonce, 3, type: :bytes
  field :encrypted_key, 4, type: :bytes
end

defmodule NknClient.Proto.Payloads.Payload do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: NknClient.Proto.Payloads.PayloadType.t(),
          message_id: binary,
          data: binary,
          reply_to_id: binary,
          no_reply: boolean
        }
  defstruct [:type, :message_id, :data, :reply_to_id, :no_reply]

  field :type, 1, type: NknClient.Proto.Payloads.PayloadType, enum: true
  field :message_id, 2, type: :bytes
  field :data, 3, type: :bytes
  field :reply_to_id, 4, type: :bytes
  field :no_reply, 5, type: :bool
end

defmodule NknClient.Proto.Payloads.TextData do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          text: String.t()
        }
  defstruct [:text]

  field :text, 1, type: :string
end
