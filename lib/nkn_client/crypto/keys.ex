defmodule NknClient.Crypto.Keys do
  use GenServer
  require Logger
  alias NknClient.Crypto.KeyData

  def start_link(private_key) do
    GenServer.start_link(__MODULE__,
                         %KeyData{private_key: private_key},
                         name: __MODULE__)
  end

  # Public API
  def get_public_key do
    GenServer.call(__MODULE__, :get_public)
  end

  # Generate private key
  def init(%KeyData{private_key: nil} = key_data) do
    {:ok, get_priv_pub()}
  end

  # Private key set by user TODO
  def init(%KeyData{} = key_data) do
    {:ok, key_data}
  end

  def handle_call(:get_public, _from, keys) do
    {:reply, keys.public_key, keys}
  end

  defp get_priv_pub do
    keys = :crypto.generate_key(:ecdh, :secp256r1)
    |> Tuple.to_list
    |> Enum.map(&encode/1)

    %KeyData{private_key: Enum.at(keys, 0),
             public_key: Enum.at(keys, 1)}
  end

  defp encode(key) do
    Base.encode16(key, case: :lower)
  end
end
