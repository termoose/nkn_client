defmodule NknClient.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # List all child processes to be supervised
    children = [
      supervisor(NknClient.RPC.Supervisor, []),
      supervisor(NknClient.Crypto.Supervisor, []),
      supervisor(NknClient.WS.Supervisor, []),
      {User, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NknClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
