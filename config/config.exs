# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :shopping_list, ShoppingListWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hVIL5iLFv8YUXwYuXutDpv3LgOZJGRj0H9F3RIiF9CrsHIhEqWrfbvTO8nak0I48",
  render_errors: [view: ShoppingListWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ShoppingList.PubSub,
  live_view: [signing_salt: "XRkeLn3u"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :shopping_list, ShoppingList.Mailer, adapter: Swoosh.Adapters.Local

config :swoosh, :api_client, false

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
