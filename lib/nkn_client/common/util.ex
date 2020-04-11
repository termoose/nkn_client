defmodule NknClient.Common.Util do
  def random_int_32 do
    <<n::32>> = :crypto.strong_rand_bytes(4)
    n
  end

  def hex_to_bytes(string) do
    Base.decode16!(string, case: :lower)
  end

  def bytes_to_hex(bytes) do
    Base.encode16(bytes, case: :lower)
  end

  def addr_to_pubkey(addr) when is_binary(addr) do
    addr |> String.split(".") |> List.last()
  end
end
