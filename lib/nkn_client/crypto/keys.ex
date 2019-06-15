defmodule NknClient.Crypto.Keys do
  use GenServer
  require Logger
  require Integer
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

  def get_keys do
    GenServer.call(__MODULE__, :get_keys)
  end

  # Generate private key
  def init(%KeyData{private_key: nil}) do
    {:ok, generate_keys()}
  end

  # Private key set by user
  def init(%KeyData{} = key_data) do
    {:ok, generate_keys_from_seed(key_data.seed)}
  end

  def handle_call(:get_keys, _from, keys) do
    {:reply,
     %KeyData{public_key: encode(keys.public_key),
              private_key: encode(keys.private_key),
              seed: encode(keys.seed)},
     keys}
  end

  def handle_call(:get_public, _from, keys) do
    {:reply, encode(keys.public_key), keys}
  end

  def generate_keys_from_seed(seed) do
    %{public: pub, secret: priv} = :enacl.sign_seed_keypair(decode(seed))

    %KeyData{private_key: priv,
             public_key: pub,
             seed: seed}
  end

  def generate_keys do
    %{public: pub, secret: priv} = :enacl.sign_keypair()

    %KeyData{private_key: priv,
             public_key: pub,
             seed: seed_from_private_key(priv)}
  end

  defp seed_from_private_key(private_key) do
    << seed :: binary-size(32), _ :: binary >> = private_key

    seed
  end

  defp encode(key) do
    Base.encode16(key, case: :lower)
  end

  defp decode(key) do
    Base.decode16!(key |> String.upcase)
  end

  def convert_public_key(key) do
    :enacl.crypto_sign_ed25519_public_to_curve25519(key)
  end
end
