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

  # Generate private key
  def init(%KeyData{private_key: nil}) do
    {:ok, get_priv_pub()}
  end

  # Private key set by user TODO
  def init(%KeyData{} = key_data) do
    {:ok, get_pub(key_data.private_key)}
  end

  def handle_call(:get_public, _from, keys) do
    pub_key = keys.public_key |> compress |> encode
    client_id = Application.get_env(:nkn_client, :client_id)

    {:reply,
     "#{client_id}.#{pub_key}",
     keys}
  end

  def get_pub(private_key) do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256r1, private_key |> decode)

    %KeyData{private_key: priv,
             public_key: pub}
  end

  def get_priv_pub do
    {pub, priv} = :crypto.generate_key(:ecdh, :secp256r1)

    %KeyData{private_key: priv,
             public_key: pub}
  end

  defp compress(<< 04,
                x :: binary-size(32),
                y :: binary-size(32) >>) do
    << _ :: binary-size(31), last >> = y

    case Integer.is_even(last) do
      true  -> << 02, x :: binary >>
      false -> << 03, x :: binary >>
    end
  end

  defp encode(key) do
    Base.encode16(key, case: :lower)
  end

  defp decode(key) do
    Base.decode16!(key |> String.upcase)
  end
end
