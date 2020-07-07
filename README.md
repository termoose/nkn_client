# NknClient

An Elixir client for sending and receiving messages on [NKN](https://nkn.org).
Client defaults to compressed elliptic curve points on `NIST P-256`. Support for `ed25519` will be [added in the future](https://github.com/nknorg/nkn/issues/74) once the offical nodes support it.

Automatically reconnects to the correct node from body of the `WrongNode` messages in accordance with the reference JavaScript Client.

A simple usage example

```elixir
defmodule User do
  use NknClient

  def start_link(state) do
    NknClient.start_link(__MODULE__, state)
  end

  def handle_packet(packet) do
    Logger.debug("Packet: #{inspect(packet)}")
  end
end
```

Callback that can be implemented:

- `handle_packet/1`
- `handle_update_chain/1`
- `handle_set_client/1`
- `handle_send_packet/1`
- `handle_raw_block/1`

The module `User` can then be put in a supervision tree or started manually

```elixir
{:ok, pid} = User.start_link(:ok)
```

Send packets to other users on the network

```elixir
iex> User.send_packet("some_address", "Hello, NKN!")
iex> User.send_packet(["some_address", "another_address"], "Hello, NKN!")
```

Get your own key pair and client id

```elixir
iex> User.get_keys()
iex> User.get_address()
```

## Config

Any of the fields can be left blank. If `client_id` is not specified then only the public key will be used for identification. If the `private_key` is left blank then a new one will be generated every time your application starts. If `rpc_url` is left blank the current public default one `http://testnet-node-0001.nkn.org:30003` will be used.

Do not place your private key in your repository, set it as an environment variable and access it with `System.get_env("SECRET_NKN_PRIVATE_KEY")`.

```elixir
config :nkn_client, client_id: "elixir_nkn",
                    private_key: "some_private_key",
                    rpc_url: "http://custom_seed_rpc:30003"
```

## Installation

Add `nkn_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nkn_client, "~> 0.5.0"}
  ]
end
```

## TODO

- ~~Support client id's in front of the public keys (`id.pub_key`)~~
- ~~Let users specify their own private key and calculate corresponding public key~~
- ~~Make handle functions for each of the different message types~~
- ~~Can the "Digest" in packages be decoded to reveal information about the relay?~~
- Add a non-empty `Signature` to sent messages
- ~~Store the data from updateSigChainBlockHash and expose it through the library API~~ (Callback added)
- Write more tests!
- Declare type specifications on all functions
- Investigate how we can achieve better throughput with our GenStage

## Contribution

### Generate pb.ex files from proto

``` shell
protoc \
  --proto_path=./deps/protobuf/src/ \
  --proto_path=./lib/nkn_client/proto/ \
  --elixir_out=./lib/nkn_client/proto/ \
  ./lib/nkn_client/proto/*.proto
```
