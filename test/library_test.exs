defmodule NknClientTest.LibraryTest do
  use ExUnit.Case

  defmodule NknClientTest.Library do
    use NknClient

    def start_link(state) do
      NknClient.start_link(__MODULE__, state)
    end

    def handle_packet(packet) do
      Logger.debug("Packet: #{inspect(packet)}")
    end
  end

  test "Start library" do
    {:ok, pid} = NknClientTest.Library.start_link(:ok)
  end
end
