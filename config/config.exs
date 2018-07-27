# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Public: 02ebaac4fd0af04121c779c10d14e2822efd687594f4821c2d35c146d52c72b3d7
config :nkn_client, client_id: "elixir_nkn",
                    private_key: "a41a479ed09be3a8f20c3726dd791445c851bf955c61476c07e06fd20dc09006"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :nkn_client, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:nkn_client, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
