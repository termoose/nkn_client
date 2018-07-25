defmodule NknClient do
  @moduledoc """
  Documentation for NknClient.
  """
  use GenStage

  @callback handle_event(event :: any) :: any

  defmacro __using__(opts) do
    quote do
      import Logger
      @behaviour NknClient

      def init(state) do
        {:consumer, state, subscribe_to: [NknClient.WS.MessageSink]}
      end

      def send_packet(dest, payload) do
        NknClient.WS.send(dest, payload)
      end

      def handle_event(event) do
        Logger.warn("No implementation for event: #{inspect(event)}")
      end

      def handle_events(events, _from, {module, state}) do
        for {:text, event} <- events do
          module.handle_event(event |> Poison.decode!)
        end
        {:noreply, [], {module, state}}
      end

      def child_spec(state) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [state]}
        }
        |> Supervisor.child_spec(unquote(Macro.escape(opts)))
      end

      defoverridable [handle_event: 1]
    end
  end
  
  def start_link(module, state) do
    GenStage.start_link(module, {module, state}, name: module)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [NknClient.WS.MessageSink]}
  end
end
