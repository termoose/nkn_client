defmodule User do
  use NknClient

  def start_link(state) do
    NknClient.start_link(state)
  end

  def handle_event(event) do
    IO.puts "Implemented #{inspect(event)}"
  end
end
