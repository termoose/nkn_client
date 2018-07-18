defmodule NknClient.RPC.Client do
  alias JSONRPC2.Clients.HTTP

  @url "http://cluster2-oregon.nkn.org:30003"

  def get_ws_address() do
    {:ok, host} = HTTP.call(@url, "getwsaddr", %{"address" => "some_address"})

    host
  end
end
