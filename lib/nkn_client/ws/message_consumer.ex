defmodule NknClient.WS.MessageConsumer do
  use GenStage
  require Logger

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [NknClient.WS.MessageRouter]}
  end

  def handle_events(event, _from, state) do
    Logger.debug("Consumer event: #{inspect(event)}")
    {:noreply, [], state}
  end
end
