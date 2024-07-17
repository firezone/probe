defmodule Probe.Router do
  use Probe, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Probe.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["text"]

    post "/runs/:token/start", Probe.Controllers.Run, :start
    post "/runs/:id/complete", Probe.Controllers.Run, :complete
    post "/runs/:id/cancel", Probe.Controllers.Run, :cancel
    get "/runs/:id", Probe.Controllers.Run, :show
  end

  scope "/", Probe do
    pipe_through :browser

    live_session :public do
      live "/", Live.Index, :run
      live "/stats", Live.Index, :stats_map
      live "/stats/map", Live.Index, :stats_map
      live "/stats/list", Live.Index, :stats_list
      live "/faq", Live.Index, :faq
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:probe, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Probe.Telemetry
    end
  end
end
