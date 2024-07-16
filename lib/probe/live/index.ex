defmodule Probe.Live.Index do
  use Probe, :live_view

  @default_checks %{
    handshake_initiation: nil,
    handshake_response: nil,
    cookie_reply: nil,
    data_message: nil,
    turn_handshake_initiation: nil,
    turn_handshake_response: nil,
    turn_cookie_reply: nil,
    turn_data_message: nil
  }

  @default_port 51_820

  # This should match the token lifetime
  @timer_ms 3_600_000

  def mount(_params, _session, socket) do
    topic = :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
    :ok = Probe.PubSub.subscribe("run:#{topic}")

    os =
      case UAParser.parse(get_connect_info(socket, :user_agent)) do
        %UAParser.UA{os: %UAParser.OperatingSystem{family: os}} -> os
        _ -> "Unknown"
      end

    if connected?(socket) do
      schedule_reset_token()
    end

    {:ok,
     assign(socket,
       checks: @default_checks,
       topic: topic,
       port: @default_port,
       token: init(topic, @default_port),
       os: os,
       status: "Waiting for test to start..."
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-grow">
      <div class="w-full flex items-center">
        <div class="hidden sm:flex sm:w-1/3">
          <div class="m-4 lg:w-64 lg:h-24 md:w-48 md:h-16 sm:w-32 sm:h-12 min-w-32 bg-contain bg-logo-light dark:bg-logo-dark bg-no-repeat" />
        </div>
        <div class="flex w-full md:w-1/3 justify-center items-center bg-gray-50 dark:bg-gray-900 py-5">
          <nav
            id="toggleMobileMenu"
            class="bg-gray-50 border-b border-gray-200 dark:bg-gray-900 block mx-auto dark:border-gray-800"
          >
            <div class="flex items-center">
              <ul class="flex flex-row mt-0 w-full text-xs sm:text-sm md:text-md font-medium">
                <li class="inline dark:border-gray-700 border-b-0">
                  <.link navigate="/" class={tab_class(@live_action, [:run])}>
                    Run test
                  </.link>
                </li>
                <li class="inline dark:border-gray-700 border-b-0">
                  <.link navigate="/stats" class={tab_class(@live_action, [:stats_map, :stats_table])}>
                    View stats
                  </.link>
                </li>
                <li class="inline dark:border-gray-700 border-b-0">
                  <.link navigate="/faq" class={tab_class(@live_action, [:faq])}>
                    FAQ
                  </.link>
                </li>
              </ul>
            </div>
          </nav>
        </div>
        <div class="md:w-1/3 mx-2 flex justify-end">
          <button
            id="theme-toggle"
            phx-hook="DarkModeToggle"
            type="button"
            class="text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5"
          >
            <svg
              id="theme-toggle-dark-icon"
              class="hidden w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
            </svg>
            <svg
              id="theme-toggle-light-icon"
              class="hidden w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z"
                fill-rule="evenodd"
                clip-rule="evenodd"
              >
              </path>
            </svg>
          </button>
        </div>
      </div>
      <div class="pb-24">
        <main class="dark:bg-gray-900 flex-1 p-4 space-y-4">
          <%= if @live_action == :run do %>
            <.live_component
              module={Probe.Live.Component.Run}
              id="run"
              token={@token}
              os={@os}
              port={@port}
              status={@status}
              checks={@checks}
            />
          <% end %>
          <%= if @live_action in [:stats_map, :stats_list] do %>
            <.live_component module={Probe.Live.Component.Results} id="results" tab={@live_action} />
          <% end %>
          <%= if @live_action == :faq do %>
            <.live_component module={Probe.Live.Component.Faq} id="faq" />
          <% end %>
        </main>
      </div>
    </div>
    """
  end

  defp tab_class(live_action, action) do
    common = "block py-3 px-4"

    if live_action in action do
      ~w[
        #{common}
        border-b-2
        text-primary-600
        hover:text-primary-600
        dark:text-primary-500
        dark:border-primary-500
        border-primary-600
      ]
    else
      ~w[
        #{common}
        text-gray-500
        dark:text-gray-400
        hover:text-primary-600
        hover:border-b-2
        dark:hover:text-primary-500
        dark:hover:border-primary-500
        hover:border-primary-600
      ]
    end
  end

  def handle_info(:started, socket) do
    {:noreply,
     assign(socket,
       checks: @default_checks,
       status: "Test running..."
     )}
  end

  def handle_info(:reset_token, socket) do
    schedule_reset_token()
    {:noreply, assign(socket, token: init(socket.assigns.topic, socket.assigns.port))}
  end

  def handle_info({:completed, run_id}, socket) do
    {:noreply, complete(run_id, socket)}
  end

  # Canceled by user, likely Ctrl+C or script error
  def handle_info({:canceled, run_id}, socket) do
    with {:ok, run} <- Probe.Runs.fetch_run(run_id),
         nil <- run.completed_at,
         {:ok, _run} <-
           Probe.Runs.update_run(run, %{
             checks: socket.assigns.checks,
             completed_at: DateTime.utc_now()
           }) do
      {:noreply,
       assign(socket,
         status: "Test canceled!"
       )}
    else
      _already_canceled ->
        {:noreply, socket}
    end
  end

  def handle_info({event, run_id}, socket) do
    checks = Map.put(socket.assigns.checks, event, true)
    socket = assign(socket, checks: checks)

    if Enum.all?(checks, fn {_k, v} -> v end) do
      {:noreply, complete(run_id, socket)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("port_change", %{"port" => port}, socket) do
    {:noreply, assign(socket, token: init(socket.assigns.topic, port), port: port)}
  end

  defp schedule_reset_token() do
    Process.send_after(self(), :reset_token, @timer_ms)
  end

  defp init(topic, port) do
    Phoenix.Token.sign(Probe.Endpoint, "topic", %{
      topic: topic,
      port: port
    })
  end

  defp complete(run_id, socket) do
    with {:ok, run} <- Probe.Runs.fetch_run(run_id),
         nil <- run.completed_at,
         {:ok, run} <-
           Probe.Runs.update_run(run, %{
             checks: socket.assigns.checks,
             completed_at: DateTime.utc_now()
           }) do
      Probe.Stats.upsert(run)
      assign(socket,
        status: "Test succeeded!"
      )
    else
      _already_completed ->
        # Most likely succeeded already
        socket
    end
  end
end
