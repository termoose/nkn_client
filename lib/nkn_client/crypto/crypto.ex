defmodule NknClient.Crypto do
  def address do
    NknClient.Crypto.Keys.get_keys().public_key
    |> get_address
  end

  def keys do
    NknClient.Crypto.Keys.get_keys()
  end

  defp get_address(key) do
    case Application.get_env(:nkn_client, :client_id) do
      nil -> key
      client_id -> "#{client_id}.#{key}"
    end
  end
end
