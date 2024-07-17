defmodule Probe.Endpoint do
  use Phoenix.Endpoint, otp_app: :probe

  @session_options [
    store: :cookie,
    key: "_probe_key",
    signing_salt: Application.compile_env!(:probe, [:session, :signing_salt]),
    encryption_salt: Application.compile_env!(:probe, [:session, :encryption_salt]),
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [:user_agent, session: @session_options]],
    longpoll: [connect_info: [:user_agent, session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :probe,
    gzip: false,
    only: Probe.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :probe
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId, http_header: "fly-request-id"
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug :fetch_session
  plug :put_session_id
  plug Probe.Router

  def put_session_id(conn, _opts) do
    if Plug.Conn.get_session(conn, :session_id) do
      conn
    else
      Plug.Conn.put_session(conn, :session_id, Ecto.UUID.generate())
    end
  end
end
