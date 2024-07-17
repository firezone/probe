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
    # {"Port Name", {external_port, internal_port}},
    {"1701 (L2TP)", 1701},
    {"8080", 8080},
    {"8443", 8443},
    {"10000", 10000},
    {"20000", 20000},
    {"30000", 30000},
    {"40000", 40000},
    {"50000", 50000},
    {"51820 (WireGuard)", 51820},
    {"60000", 60000}
  ]

config :probe, Probe.Repo,
  migration_timestamps: [type: :timestamptz],
  start_apps_before_migration: [:ssl, :logger_json]

# Configures the endpoint
config :probe, Probe.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [
      html: Probe.Controllers.ErrorHTML,
      json: Probe.Controllers.ErrorJSON
    ],
    layout: false
  ],
  pubsub_server: Probe.PubSub,
  live_view: [signing_salt: "0PeI+5mX"]

config :probe, :session,
  signing_salt: "p//dOtPa",
  encryption_salt: "p//dOtPa"

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
