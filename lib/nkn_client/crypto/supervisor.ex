defmodule NknClient.Crypto.Supervisor do
  use Supervisor
  alias NknClient.Crypto

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Crypto.Keys, nil}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
