defmodule NknClient.Common.Hash do
  def sha_256_bytes(data) do
    :crypto.hash(:sha256, data)
  end
end
