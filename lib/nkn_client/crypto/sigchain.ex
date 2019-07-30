defmodule NknClient.Crypto.SigChain do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def set(hash) do
    GenServer.cast(__MODULE__, {:set, hash})
  end

  def get_hash do
    GenServer.call(__MODULE__, :get)
  end

  def handle_cast({:set, hash}, state) do
    {:noreply, hash}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
