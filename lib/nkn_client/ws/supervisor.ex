defmodule NknClient.WS.Supervisor do
  use Supervisor
  alias NknClient.WS
  alias NknClient.RPC

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
		IO.puts("WS address: #{inspect(RPC.get_address())}")
		
    children = [
      {WS.Client, "ws://#{RPC.get_address()}"},
      {WS.MessageSink, []},
      {WS, :ok}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
