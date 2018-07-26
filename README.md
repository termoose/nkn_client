# NknClient

An Elixir client for sending and receiving messages on [NKN](https://nkn.org).
Client defaults to compressed elliptic curve points on `NIST P-256`.

A simple usage example

```elixir
defmodule User do
  use NknClient

  def start_link(state) do
    NknClient.start_link(__MODULE__, state)
  end

  def handle_event(event) do
    Logger.debug("Event: #{inspect(event)}")
  end
end
```

The module `User` can then be put in a supervision tree or started manually

```elixir
{:ok, pid} = User.start_link(:ok)
```

Send packets to other users on the network

```elixir
iex> User.send_packet("some_address", "Hello, NKN!")

```

## Installation

Add `nkn_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nkn_client, "~> 0.1.0"}
  ]
end
```

## TODO

- Support client id's in front of the public keys (`id.pub_key`)
- Let users specify their own private key and calculate corresponding public key
- Make handle functions for each of the different message types
- Write more tests!
- Declare type specifications on all functions
- Investigate how we can achieve better throughput with our GenStage