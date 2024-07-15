import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :probe, Probe.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :geolix,
  databases: [
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: "/usr/local/share/GeoIP/GeoLite2-City.mmdb"
    },
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      source: "/usr/local/share/GeoIP/GeoLite2-Country.mmdb"
    },
    %{
      id: :asn,
      adapter: Geolix.Adapter.MMDB2,
      source: "/usr/local/share/GeoIP/GeoLite2-ASN.mmdb"
    }
  ]

config :probe,
  port_options: [
    # {"Port Name", {external_port, internal_port}},
    {"53 (DNS)", 53},
    {"69 (TFTP)", 69},
    {"80 (HTTP)", 80},
    {"123 (NTP)", 123},
    {"443 (HTTPS)", 123},
    {"500 (IKE)", 500},
    {"514 (Syslog)", 514},
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

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
