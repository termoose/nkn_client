defmodule NknClient.RPC.Client do
  alias JSONRPC2.Clients.HTTP

  @url "http://cluster2-oregon.nkn.org:30003"

  def get_ws_address() do
    {:ok, host} = HTTP.call(@url, "getwsaddr", %{"address" => "client.0396afc4d7ea198d8c3986ba6ed509f4d8d8635804a63571339cb6104a6a279858"})

    host
  end
end
