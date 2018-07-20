defmodule NknClient.WS.MessageSink do
  use GenStage
  require Logger

  def start_link(messages) do
    GenStage.start_link(__MODULE__, messages, name: __MODULE__)
  end

  def handle(msg) do
    GenStage.cast(__MODULE__, {:handle, msg})
  end

  def init(messages) do
    {:producer, messages}
  end

  def handle_cast({:handle, msg}, messages) do
    {:noreply, [msg], messages}
  end

  def handle_demand(demand, messages) do
    {out_events, remaining_events} = Enum.split(messages, demand)
    {:noreply, out_events, remaining_events}
  end
end
