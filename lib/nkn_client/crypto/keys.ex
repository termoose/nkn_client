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

  def encrypt(message, pub_key) do
    GenServer.call(__MODULE__, {:encrypt, message, pub_key})
  end

  def decrypt(message, pub_key, nonce) do
    GenServer.call(__MODULE__, {:decrypt, message, pub_key, nonce})
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

  def handle_call({:encrypt, message, pub_key}, _from, keys) do
    {:reply, encrypt(message, pub_key, keys.seed), keys}
  end

  def handle_call({:decrypt, message, pub_key, nonce}, _from, keys) do
    {:reply, decrypt(message, pub_key, nonce, keys.seed), keys}
  end

  # This shared secret should be cached in an ETS table
  defp get_shared_key(other_pub_key, seed) do
    other_curve_pub_key = other_pub_key
    |> String.upcase
    |> Base.decode16!
    |> :enacl.crypto_sign_ed25519_public_to_curve25519

    :enacl.box_beforenm(other_curve_pub_key, seed)
  end

  defp encrypt(message, dest_pub_key, seed) do
    shared_secret = get_shared_key(dest_pub_key, seed)
    nonce = random_nonce()

    %{cipher_text: :enacl.box_afternm(message, nonce, shared_secret),
      nonce: nonce}
  end

  defp decrypt(message, src_pub_key, nonce, seed) do
    shared_secret = get_shared_key(src_pub_key, seed)

    :enacl.box_open_afternm(message, nonce, shared_secret)
  end

  defp generate_keys_from_seed(seed) do
    %{public: pub, secret: priv} = :enacl.sign_seed_keypair(decode(seed))

    %KeyData{private_key: priv,
             public_key: pub,
             seed: seed}
  end

  defp generate_keys do
    %{public: pub, secret: priv} = :enacl.sign_keypair()

    %KeyData{private_key: priv,
             public_key: pub,
             seed: seed_from_private_key(priv)}
  end

  defp seed_from_private_key(private_key) do
    << seed :: binary-size(32), _ :: binary >> = private_key

    seed
  end

  defp random_nonce do
    :enacl.randombytes(:enacl.box_nonce_size)
  end

  defp encode(key) do
    Base.encode16(key, case: :lower)
  end

  defp decode(key) do
    Base.decode16!(key |> String.upcase)
  end
end
