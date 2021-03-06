# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :bt_position_web_ui, BtPositionWebUiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vfCzlf3CnVjjPyCTgBgHwMAWthQLVIk+u1jGRtpPbd8gP682zJIqI9aOobU6Jzuk",
  render_errors: [view: BtPositionWebUiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BtPositionWebUi.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: System.get_env("LIVEVIEW_SALT")
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
