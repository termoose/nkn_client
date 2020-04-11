defmodule NknClient.RPC.Client do
  use GenServer
  alias JSONRPC2.Clients.HTTP

  # @default_url "http://testnet-node-0001.nkn.org:30003"
  # @default_url "http://devnet-seed-0001.nkn.org:30003"
  @default_url "http://mainnet-seed-0001.nkn.org:30003"

  # @default_url "http://sia.anoncat.com:30003"

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Initialize the state to nil as we don't have a cached
  # RPC address until :set_rpc is handled
  def init(_state) do
    {:ok, nil}
  end

  # Client
  def get_addr do
    GenServer.call(__MODULE__, :get_rpc)
  end

  def set_addr(address) do
    GenServer.cast(__MODULE__, {:set_rpc, address})
  end

  # Server
  def handle_cast({:set_rpc, rpc}, _rpc_address) do
    {:noreply, rpc}
  end

  def handle_call(:get_rpc, _from, rpc_address) do
    case rpc_address do
      nil -> {:reply, get_ws_address(), rpc_address}
      _ -> {:reply, rpc_address, rpc_address}
    end
  end

  def get_ws_address do
    case Application.get_env(:nkn_client, :rpc_url) do
      nil -> get_host(@default_url)
      url -> get_host(url)
    end
  end

  defp get_host(url) do
    {:ok, host} = HTTP.call(url, "getwsaddr", %{"address" => "#{NknClient.Crypto.address()}"})

    # We only care about the RPC address for now
    %{"addr" => addr} = host
    addr
  end
end
