defmodule NknClient.WS.MessageRouter do
  use GenStage
  require Logger

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state,
     subscribe_to: [NknClient.WS.MessageSink]}
  end

  def handle_events(events, _from, state) do
    json_events = events
    |> Enum.map(&Poison.decode!/1)

    {:noreply, json_events, state}
  end
end
