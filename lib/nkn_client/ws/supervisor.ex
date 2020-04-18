defmodule NknClient.WS.Supervisor do
  use Supervisor
  alias NknClient.WS
  alias NknClient.RPC

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {WS.Client, "ws://#{RPC.get_address()}"},
      {WS.MessageSink, []},
      {WS.NodeInfo, :ok},
      {WS, :ok}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
