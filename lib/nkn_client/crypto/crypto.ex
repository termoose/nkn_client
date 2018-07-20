defmodule NknClient.Crypto do
  def public_key do
    NknClient.Crypto.Keys.get_public_key()
  end
end
