defmodule NknClient do
  @moduledoc """
  Documentation for NknClient.
  """
  use GenStage

  @callback handle_packet(event :: any) :: any
  @callback handle_update_chain(event :: any) :: any
  @callback handle_set_client(event :: any) :: any
  @callback handle_send_packet(event :: any) :: any

  defmacro __using__(opts) do
    quote do
      import Logger
      @behaviour NknClient

      def init(state) do
        {:consumer, state, subscribe_to: [{NknClient.WS.MessageSink,
                                           cancel: :temporary}]}
      end

      def send_packet(dest, payload) do
        NknClient.WS.send(dest, payload)
      end

      def get_keys do
        NknClient.Crypto.keys()
      end

      def get_address do
        NknClient.Crypto.address()
      end

      # Default implementations
      def handle_packet(_event) do
        Logger.debug("No implementation of #{pretty_func(__ENV__.function)}")
      end

      def handle_update_chain(_event) do
        Logger.debug("No implementation of #{pretty_func(__ENV__.function)}")
      end

      def handle_set_client(_event) do
        Logger.debug("No implementation of #{pretty_func(__ENV__.function)}")
      end

      def handle_send_packet(_event) do
        Logger.debug("No implementation of #{pretty_func(__ENV__.function)}")
      end

      # FIXME: more actions need to be added here as they are discovered
      def handle_text_event({module, %{"Action" => action} = event}) do
        case action do
          "setClient" ->
            module.handle_set_client(event)
          "updateSigChainBlockHash" ->
            module.handle_update_chain(event)
          "sendPacket" ->
            module.handle_send_packet(event)
          "receivePacket" ->
            module.handle_packet(event)
        end
      end

      # Binary events are every protobuffer message received
      def handle_binary_event({module, event}) do
        module.handle_packet(event)
      end

      def handle_events(events, _from, {module, state}) do
        Enum.map(events, fn
          {:text, event} ->
            handle_text_event({module, event |> Poison.decode!})

          event ->
            handle_binary_event({module, event})
        end)

        {:noreply, [], {module, state}}
      end

      def child_spec(state) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [state]}
        }
        |> Supervisor.child_spec(unquote(Macro.escape(opts)))
      end

      defp pretty_func({func, arity}) do
        "#{Atom.to_string(func)}/#{arity}"
      end

      defoverridable [handle_packet: 1, handle_update_chain: 1,
                      handle_set_client: 1, handle_send_packet: 1]
    end
  end

  def start_link(module, state) do
    GenStage.start_link(module, {module, state}, name: module)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [{NknClient.WS.MessageSink,
                                       cancel: :temporary}]}
  end
end
