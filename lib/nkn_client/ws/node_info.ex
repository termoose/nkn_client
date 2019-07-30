defmodule NknClient.WS.NodeInfo do
  defstruct block_hash: nil, public_key: nil
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  # Client
  def set_public_key(public_key) do
    GenServer.cast(__MODULE__, {:set_key, public_key})
  end

  def set_block_hash(block_hash) do
    GenServer.cast(__MODULE__, {:set_hash, block_hash})
  end

  def get_public_key do
    GenServer.call(__MODULE__, :get_key)
  end

  def get_block_hash do
    GenServer.call(__MODULE__, :get_hash)
  end

  # Server
  def handle_cast({:set_key, key}, state) do
    {:noreply, %{state | public_key: key}}
  end

  def handle_cast({:set_hash, hash}, state) do
    {:noreply, %{state | block_hash: hash}}
  end

  def handle_call(:get_key, _from, state) do
    {:reply, state.public_key, state}
  end

  def handle_call(:get_hash, _from, state) do
    {:reply, state.block_hash, state}
  end
end
