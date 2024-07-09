import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :probe, Probe.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "probe_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :probe, Probe.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QVealHzfNFkJpJIrDkZ6f7mWg9SmHtOqfbxOO0v7SgD4T3O20TXogttCjGmqquXN",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

config :geolix,
  databases: [
    %{
      id: :city,
      adapter: Geolix.Adapter.Fake,
      data: %{
        {127, 0, 0, 1} => %{
          city: %{
            name: "Mérida"
          },
          continent: %{
            code: "NA",
            name: "North America"
          },
          country: %{
            iso_code: "MX",
            name: "Mexico"
          },
          location: %{
            latitude: 1.0,
            longitude: -1.0
          },
          registered_country: %{
            iso_code: "MX",
            name: "Mexico"
          },
          traits: %{
            ip_address: {127, 0, 0, 1}
          }
        }
      }
    },
    %{
      id: :asn,
      adapter: Geolix.Adapter.Fake,
      data: %{
        {127, 0, 0, 1} => %{
          autonomous_system_number: 17072,
          autonomous_system_organization: "TOTAL PLAY TELECOMUNICACIONES SA DE CV",
          ip_address: {127, 0, 0, 1}
        }
      }
    }
  ]
