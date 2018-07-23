defmodule NknClient do
  @moduledoc """
  Documentation for NknClient.
  """
  use GenStage

  defmacro __using__(_) do
    quote do
      @behaviour NknClient

      def handle_event(event) do
        IO.puts "Implement me!"
      end

      defoverridable [handle_event: 1]
    end
  end
  
  @callback handle_event(event :: any) :: any
  @callback handle_events(events :: any, from :: any, state :: any) :: any
  
  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [NknClient.WS.MessageSink]}
  end

#  def handle_event(event) do
#    IO.puts "Event :#{inspect(event)}"
  #  end

  def handle_events(events, _from, state) do
    for event <- events do
      handle_event(event)
    end
    {:noreply, [], state}
  end
end
