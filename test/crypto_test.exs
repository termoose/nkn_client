defmodule NknClientTest.Crypto do
  use ExUnit.Case

  test "get public key" do
    key = NknClient.Crypto.pub_key()
    <<first_byte::binary-size(2), _::binary>> = key
    assert String.length(key) == 64
  end
end
