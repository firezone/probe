defmodule Probe.Live.Index do
  use Probe, :live_view

  def mount(_params, _session, socket) do
    os =
      case UAParser.parse(get_connect_info(socket, :user_agent)) do
        %UAParser.UA{os: %UAParser.OperatingSystem{family: os}} -> os
        _ -> "Unknown"
      end

    {:ok,
     assign(socket,
       checks: %Probe.Runs.Run{}.checks,
       os: os,
       output: "Waiting on test to start..."
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <div class="w-full flex items-center">
        <div class="hidden md:flex md:w-1/3">
          <div class="m-4 w-48 h-16 min-w-24 bg-contain bg-logo-light dark:bg-logo-dark bg-no-repeat" />
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
                  <.link
                    navigate="/results"
                    class={tab_class(@live_action, [:results_map, :results_table])}
                  >
                    View results
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
            <.live_component module={Probe.Live.Component.Run} id="run" os={@os} output={@output} />
          <% end %>
          <%= if @live_action in [:results_map, :results_table] do %>
            <.live_component module={Probe.Live.Component.Results} id="results" />
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

  def handle_info({:started, %{remote_ip: remote_ip}}, socket) do
    {:noreply,
     assign(socket,
       status: :started,
       output:
         socket.assigns.output <>
           "\nTest started! Remote IP: #{:inet.ntoa(remote_ip)}\n"
     )}
  end

  def handle_info(:handshake_initiation, socket) do
    checks = Map.put(socket.assigns.checks, "handshake_initiation", true)

    {:noreply,
     assign(socket,
       checks: checks,
       output:
         socket.assigns.output <>
           "\nHandshake initiation received!"
     )}
  end

  def handle_info(:handshake_response, socket) do
    checks = Map.put(socket.assigns.checks, "handshake_response", true)

    {:noreply,
     assign(socket,
       checks: checks,
       output:
         socket.assigns.output <>
           "\nHandshake response received!"
     )}
  end

  def handle_info(:cookie_reply, socket) do
    checks = Map.put(socket.assigns.checks, "cookie_reply", true)

    {:noreply,
     assign(socket,
       checks: checks,
       output:
         socket.assigns.output <>
           "\nCookie reply received!"
     )}
  end

  def handle_info(:data_message, socket) do
    checks = Map.put(socket.assigns.checks, "data_message", true)

    {:noreply,
     assign(socket,
       checks: checks,
       output:
         socket.assigns.output <>
           "\nData message received!"
     )}
  end

  def handle_info({:completed, run_id}, socket) do
    with {:ok, run} <- Probe.Runs.fetch_run(run_id),
         nil <- run.completed_at,
         {:ok, run} <-
           Probe.Runs.update_run(run, %{
             checks: socket.assigns.checks,
             completed_at: DateTime.utc_now()
           }) do
      Probe.Stats.upsert(run)

      {:noreply,
       assign(socket,
         output:
           socket.assigns.output <>
             ~s"""

             \nTest completed!

             Results:

             Handshake initiation: #{run.checks["handshake_initiation"]}
             Handshake response: #{run.checks["handshake_response"]}
             Cookie reply: #{run.checks["cookie_reply"]}
             Data message: #{run.checks["data_message"]}
             """
       )}
    else
      _already_completed ->
        # Most likely succeeded already
        {:noreply, socket}
    end
  end

  # Canceled by user, likely Ctrl+C or script error
  def handle_info({:canceled, run_id}, socket) do
    with {:ok, run} <- Probe.Runs.fetch_run(run_id),
         nil <- run.completed_at,
         {:ok, run} <-
           Probe.Runs.update_run(run, %{
             checks: socket.assigns.checks,
             completed_at: DateTime.utc_now()
           }) do
      {:noreply,
       assign(socket,
         output: socket.assigns.output <> "\n\nTest canceled!\n\nResults: #{inspect(run.checks)}"
       )}
    else
      _already_completed ->
        # Most likely succeeded already
        {:noreply, socket}
    end
  end
end
