defmodule NknClientTest do
  use ExUnit.Case
  doctest NknClient

  test "greets the world" do
    assert NknClient.hello() == :world
  end
end
