defmodule NknClientTest.Library do
  use NknClient

  def start_link(opts) do
    NknClient.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_text(msg) do
    IO.inspect msg
  end
end
