defmodule NknClient.RPC do
  alias NknClient.RPC

  def get_address do
    RPC.Client.get_addr()
  end

  def set_address(address) do
    RPC.Client.set_addr(address)
  end
end
