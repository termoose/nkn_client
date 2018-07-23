defmodule NknClientTest.LibraryTest do
  use ExUnit.Case

  test "Start library" do
    {:ok, pid} = User.start_link(:ok)
  end
end
