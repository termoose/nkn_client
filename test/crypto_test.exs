defmodule NknClientTest.Crypto do
  use ExUnit.Case

  test "get public key" do
    key = NknClient.Crypto.public_key
    <<first_byte :: binary-size(2), _ :: binary>> = key
    assert String.length(key) == 66
    assert first_byte == "02" or first_byte == "03"
  end
end
