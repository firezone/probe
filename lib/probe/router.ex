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

    post "/runs/:token", Probe.Controllers.Run, :start
  end

  # Other scopes may use custom stacks.
  # scope "/api", Probe do
  #   pipe_through :api
  # end

  scope "/", Probe do
    pipe_through :browser

    get "/runs/:token", Controllers.Run, :show

    live "/", Live.Index, :run
    live "/results", Live.Index, :results_map
    live "/results/list", Live.Index, :results_list
    live "/faq", Live.Index, :faq
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
