# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :probe,
  ecto_repos: [Probe.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true],
  udp_bind_address: {127, 0, 0, 1},
  port_options: [
    # Needs root to run. These are enabled on Fly for prod.
    # {"53 (DNS)", 53},
    # {"80 (HTTP)", 80},
    # {"123 (NTP)", 123},
    # {"161 (SNMP)", 161},
    # {"443 (HTTPS)", 443},
    # {"500 (IKE)", 500},
    # {"514 (Syslog)", 514},
    {"1701 (L2TP)", 1701},
    {"51820 (WireGuard)", 51_820},
    {"60000", 60_000}
  ]

config :probe, Probe.Repo,
  migration_timestamps: [type: :timestamptz],
  start_apps_before_migration: [:ssl, :logger_json]

# Configures the endpoint
config :probe, Probe.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: Probe.ErrorHTML, json: Probe.ErrorJSON],
    layout: false
  ],
  pubsub_server: Probe.PubSub,
  live_view: [signing_salt: "0PeI+5mX"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  probe: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  probe: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
