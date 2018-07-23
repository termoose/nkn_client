defmodule NknClient.WS.Supervisor do
  use Supervisor
  alias NknClient.WS
  alias NknClient.RPC

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {WS.Client, "ws://#{RPC.Client.get_ws_address()}"},
#      {WS.MessageHandler, []},
      {WS.MessageSink, []},
#      {WS.MessageRouter, []},
#      {WS.MessageConsumer, :some_state},
      {WS, :ok}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
