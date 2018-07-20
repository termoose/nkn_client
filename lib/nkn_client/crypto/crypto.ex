defmodule NknClient.Crypto do
  def public_key do
    "04" <> NknClient.Crypto.Keys.get_public_key()
  end
end
