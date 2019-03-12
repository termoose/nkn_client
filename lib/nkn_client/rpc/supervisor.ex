defmodule NknClient.RPC.Supervisor do
  use Supervisor
  alias NknClient.RPC

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {RPC.Client, :ok}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
