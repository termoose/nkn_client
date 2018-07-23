defmodule NknClient.WS.MessageConsumer do
  use GenStage
  require Logger

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [NknClient.WS.MessageSink]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      Logger.debug("Event: #{inspect(event)}")
    end
    {:noreply, [], state}
  end
end
