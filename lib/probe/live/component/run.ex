defmodule Probe.Live.Component.Run do
  use Probe, :live_component

  def mount(socket) do
    if connected?(socket) do
      {:ok,
       assign(socket,
         port_options: Application.fetch_env!(:probe, :port_options)
       )}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-md mx-auto">
      <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-800 dark:text-gray-200">
          Test your WireGuard connectivity
        </h1>
        <p class="underline text-gray-600 dark:text-gray-400 mt-4">
          <i>No WireGuard® client required!</i>
        </p>
      </div>
      <%= if @os && @os =~ ~r/(Mac OS X|Windows|Linux|FreeBSD|OpenBSD)/ do %>
        <%= if connected?(@socket) do %>
          <h3 class="text-xl mb-4 font-semibold text-gray-900 dark:text-white">
            Step 1: Choose your operating system:
          </h3>
          <div class="w-full mb-8">
            <div class="inline-flex rounded-md shadow-sm" role="group">
              <button phx-click={show_macos()} id="macos-btn" type="button" class={~w[
                inline-flex
                items-center
                px-4
                py-2
                text-sm
                font-medium
                #{selected_class(@os, "Mac OS X")}
                bg-white
                border
                border-gray-200
                rounded-s-lg
                hover:bg-gray-100
                hover:text-blue-700
                focus:z-10
                focus:ring-2
                focus:ring-blue-700
                focus:text-blue-700
                dark:border-gray-700
                dark:text-white
                dark:hover:text-white
                dark:hover:bg-gray-700
                dark:focus:ring-blue-500
                dark:focus:text-white
              ]}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 814 1000"
                  class="w-4 h-4 me-2"
                  aria-hidden="true"
                  fill="currentColor"
                >
                  <path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76.5 0-103.7 40.8-165.9 40.8s-105.6-57-155.5-127C46.7 790.7 0 663 0 541.8c0-194.4 126.4-297.5 250.8-297.5 66.1 0 121.2 43.4 162.7 43.4 39.5 0 101.1-46 176.3-46 28.5 0 130.9 2.6 198.3 99.2zm-234-181.5c31.1-36.9 53.1-88.1 53.1-139.3 0-7.1-.6-14.3-1.9-20.1-50.6 1.9-110.8 33.7-147.1 75.8-28.5 32.4-55.1 83.6-55.1 135.5 0 7.8 1.3 15.6 1.9 18.1 3.2.6 8.4 1.3 13.6 1.3 45.4 0 102.5-30.4 135.5-71.3z" />
                </svg>
                macOS
              </button>
              <button phx-click={show_windows()} id="windows-btn" type="button" class={~w[
                inline-flex
                items-center
                px-4
                py-2
                text-sm
                font-medium
                #{selected_class(@os, "Windows")}
                bg-white
                border-t
                border-b
                border-gray-200
                hover:bg-gray-100
                hover:text-blue-700
                focus:z-10
                focus:ring-2
                focus:ring-blue-700
                focus:text-blue-700
                dark:border-gray-700
                dark:text-white
                dark:hover:text-white
                dark:hover:bg-gray-700
                dark:focus:ring-blue-500
                dark:focus:text-white
              ]}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-4 h-4 me-2"
                  fill="currentColor"
                  viewBox="0 0 4875 4875"
                >
                  <path d="M0 0h2311v2310H0zm2564 0h2311v2310H2564zM0 2564h2311v2311H0zm2564 0h2311v2311H2564" />
                </svg>
                Windows
              </button>
              <button phx-click={show_linux()} id="linux-btn" type="button" class={~w[
                inline-flex
                items-center
                px-4
                py-2
                text-sm
                font-medium
                #{selected_class(@os, ~r/(Linux|FreeBSD|OpenBSD)/)}
                bg-white
                border
                border-gray-200
                rounded-e-lg
                hover:bg-gray-100
                hover:text-blue-700
                focus:z-10
                focus:ring-2
                focus:ring-blue-700
                focus:text-blue-700
                dark:border-gray-700
                dark:text-white
                dark:hover:text-white
                dark:hover:bg-gray-700
                dark:focus:ring-blue-500
                dark:focus:text-white
              ]}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="currentColor"
                  class="w-4 h-4 me-2"
                  viewBox="0 0 266 312"
                >
                  <path
                    stroke="currentColor"
                    stroke-width="10"
                    d="M128.6640625 79.2793c0 1-1 1-1 1h-1c-1 0-1-1-2-2 0 0-1-1-1-2s0-1 1-1l2 1c1 1 2 2 2 3m-18-10c0-5-2-8-5-8 0 0 0 1-1 1v2h3c0 2 1 3 1 5h2m35-5c2 0 3 2 4 5h2c-1-1-1-2-1-3s0-2-1-3-2-2-3-2c0 0-1 1-2 1 0 1 1 1 1 2m-30 16c-1 0-1 0-1-1s0-2 1-3c2 0 3-1 3-1 1 0 1 1 1 1 0 1-1 2-3 4h-1m-11-1c-4-2-5-5-5-10 0-3 0-5 2-7 1-2 3-3 5-3s3 1 5 3c1 3 2 6 2 9v2h1v-1c1 0 1-2 1-6 0-3 0-6-2-9s-4-5-8-5c-3 0-6 2-7 5-2 4-2.4 7-2.4 12 0 4 1.4 8 5.4 12 1-1 2-1 3-2m125 141c1 0 1-.4 1-1.3 0-2.2-1-4.8-4-7.7-3-3-8-4.9-14-5.7-1-.1-2-.1-2-.1-1-.2-1-.2-2-.2-1-.1-3-.3-4-.5 3-9.3 4-17.5 4-24.7 0-10-2-17-6-23s-8-9-13-10c-1 1-1 1-1 2 5 2 10 6 13 12 3 7 4 13 4 20 0 5.6-1 13.9-5 24.5-4 1.6-8 5.3-11 11.1 0 .9 0 1.4 1 1.4 0 0 1-.9 2-2.6 2-1.7 3-3.4 5-5.1 3-1.7 5-2.6 8-2.6 5 0 10 .7 13 2.1 4 1.3 6 2.7 7 4.3 1 1.5 2 2.9 3 4.2 0 1.3 1 1.9 1 1.9m-92-145c-1-1-1-3-1-5 0-4 0-6 2-9 2-2 4-3 6-3 3 0 5 2 7 4 1 3 2 5 2 8 0 5-2 8-6 9 0 0 1 1 2 1 2 0 3 1 5 2 1-6 2-10 2-15 0-6-1-10-3-13-3-3-6-4-10-4-3 0-6 1-9 3-2 3-3 5-3 8 0 5 1 9 3 13 1 0 2 1 3 1m12 16c-13 9-23 13-31 13-7 0-14-3-20-8 1 2 2 4 3 5l6 6c4 4 9 6 14 6 7 0 15-4 25-11l9-6c2-2 4-4 4-7 0-1 0-2-1-2-1-2-6-5-16-8-9-4-16-6-20-6-3 0-8 2-15 6-6 4-10 8-10 12 0 0 1 1 2 3 6 5 12 8 18 8 8 0 18-4 31-14v2c1 0 1 1 1 1m23 202c4 7.52 11 11.3 19 11.3 2 0 4-.3 6-.9 2-.4 4-1.1 5-1.9 1-.7 2-1.4 3-2.2 2-.7 2-1.2 3-1.7l17-14.7c4-3.19 8-5.98 13-8.4 4-2.4 8-4 10-4.9 3-.8 5-2 7-3.6 1-1.5 2-3.4 2-5.8 0-2.9-2-5.1-4-6.7s-4-2.7-6-3.4-4-2.3-7-5c-2-2.6-4-6.2-5-10.9l-1-5.8c-1-2.7-1-4.7-2-5.8 0-.3 0-.4-1-.4s-3 .9-4 2.6c-2 1.7-4 3.6-6 5.6-1 2-4 3.8-6 5.5-3 1.7-6 2.6-8 2.6-8 0-12-2.2-15-6.5-2-3.2-3-6.9-4-11.1-2-1.7-3-2.6-5-2.6-5 0-7 5.2-7 15.7v31.1c0 .9-1 2.9-1 6-1 3.1-1 6.62-1 10.6l-2 11.1v.17m-145-5.29c9.3 1.36 20 4.27 32.1 8.71 12.1 4.4 19.5 6.7 22.2 6.7 7 0 12.8-3.1 17.6-9.09 1-1.94 1-4.22 1-6.84 0-9.45-5.7-21.4-17.1-35.9l-6.8-9.1c-1.4-1.9-3.1-4.8-5.3-8.7-2.1-3.9-4-6.9-5.5-9-1.3-2.3-3.4-4.6-6.1-6.9-2.6-2.3-5.6-3.8-8.9-4.6-4.2.8-7.1 2.2-8.5 4.1s-2.2 4-2.4 6.2c-.3 2.1-.9 3.5-1.9 4.2-1 .6-2.7 1.1-5 1.6-.5 0-1.4 0-2.7.1h-2.7c-5.3 0-8.9.6-10.8 1.6-2.5 2.9-3.8 6.2-3.8 9.7 0 1.6.4 4.3 1.2 8.1.8 3.7 1.2 6.7 1.2 8.8 0 4.1-1.2 8.2-3.7 12.3-2.5 4.3-3.8 7.5-3.8 9.78 1 3.88 7.6 6.61 19.7 8.21m33.3-90.9c0-6.9 1.8-14.5 5.5-23.5 3.6-9 7.2-15 10.7-19-.2-1-.7-1-1.5-1l-1-1c-2.9 3-6.4 10-10.6 20-4.2 9-6.4 17.3-6.4 23.4 0 4.5 1.1 8.4 3.1 11.8 2.2 3.3 7.5 8.1 15.9 14.2l10.6 6.9c11.3 9.8 17.3 16.6 17.3 20.6 0 2.1-1 4.2-4 6.5-2 2.4-4.7 3.6-7 3.6-.2 0-.3.2-.3.7 0 .1 1 2.1 3.1 6 4.2 5.7 13.2 8.5 25.2 8.5 22 0 39-9 52-27 0-5 0-8.1-1-9.4v-3.7c0-6.5 1-11.4 3-14.6s4-4.7 7-4.7c2 0 4 .7 6 2.2 1-7.7 1-14.4 1-20.4 0-9.1 0-16.6-2-23.6-1-6-3-11-5-15l-6-9c-2-3-3-6-5-9-1-4-2-7-2-12-3-5-5-10-8-15-2-5-4-10-6-14l-9 7c-10 7-18 10-25 10-6 0-11-1-14-5l-6-5c0 3-1 7-3 11l-6.3 12c-2.8 7-4.3 11-4.6 14-.4 2-.7 4-.9 4l-7.5 15c-8.1 15-12.2 28.9-12.2 40.4 0 2.3.2 4.7.6 7.1-4.5-3.1-6.7-7.4-6.7-13m71.6 94.6c-13 0-23 1.76-30 5.25v-.3c-5 6-10.6 9.1-18.4 9.1-4.9 0-12.6-1.9-23-5.7-10.5-3.6-19.8-6.36-27.9-8.18-.8-.23-2.6-.57-5.5-1.03-2.8-.45-5.4-.91-7.7-1.37-2.1-.45-4.5-1.13-7.1-2.05-2.5-.79-4.5-1.82-6-3.07-1.38-1.26-2.06-2.68-2.06-4.27 0-1.6.34-3.31 1.02-5.13.64-1.1 1.34-2.2 2.04-3.2.7-1.1 1.3-2.1 1.7-3.1.6-.9 1-1.8 1.4-2.8.4-.9.8-1.8 1-2.9.2-1 .4-2 .4-3s-.4-4-1.2-9.3c-.8-5.2-1.2-8.5-1.2-9.9 0-4.4 1-7.9 3.2-10.4s4.3-3.8 6.5-3.8h11.5c.9 0 2.3-.5 4.4-1.7.7-1.6 1.3-2.9 1.7-4.1.5-1.2.7-2.1.9-2.5.2-.6.4-1.2.6-1.7.4-.7.9-1.5 1.6-2.3-.8-1-1.2-2.3-1.2-3.9 0-1.1 0-2.1.2-2.7 0-3.6 1.7-8.7 5.3-15.4l3.5-6.3c2.9-5.4 5.1-9.4 6.7-13.4 1.7-4 3.5-10 5.5-18 1.6-7 5.4-14 11.4-21l7.5-9c5.2-6 8.6-11 10.5-15s2.9-9 2.9-13c0-2-.5-8-1.6-18-1-10-1.5-20-1.5-29 0-7 .6-12 1.9-17s3.6-10 7-14c3-4 7-8 13-10s13-3 21-3c3 0 6 0 9 1 3 0 7 1 12 3 4 2 8 4 11 7 4 3 7 8 10 13 2 6 4 12 5 20 1 5 1 10 2 17 0 6 1 10 1 13 1 3 1 7 2 12 1 4 2 8 4 11 2 4 4 8 7 12 3 5 7 10 11 16 9 10 16 21 20 32 5 10 8 23 8 36.9 0 6.9-1 13.6-3 20.1 2 0 3 .8 4 2.2s2 4.4 3 9.1l1 7.4c1 2.2 2 4.3 5 6.1 2 1.8 4 3.3 7 4.5 2 1 5 2.4 7 4.2 2 2 3 4.1 3 6.3 0 3.4-1 5.9-3 7.7-2 2-4 3.4-7 4.3-2 1-6 3-12 5.82-5 2.96-10 6.55-15 10.8l-10 8.51c-4 3.9-8 6.7-11 8.4-3 1.8-7 2.7-11 2.7l-7-.8c-8-2.1-13-6.1-16-12.2-16-1.94-29-2.9-37-2.9"
                  />
                </svg>
                Linux/Unix
              </button>
            </div>
          </div>

          <h3 class="text-xl mb-4 font-semibold text-gray-900 dark:text-white">
            Step 2: Choose a port:
          </h3>
          <.form id="port-form" for={%{}} phx-change="port_change" phx-hook="InitFlowbite">
            <div class="mb-4">
              <div class="w-64">
                <.input
                  id="run-port"
                  name="port"
                  type="select"
                  options={@port_options}
                  value={@port}
                  phx-debounce="250"
                />
              </div>
              <p class="text-xs text-gray-500 dark:text-gray-400 my-2">
                Select a different port if you suspect WireGuard's default port is blocked.
              </p>
            </div>
          </.form>

          <div
            id="macos-instructions"
            style={(@os in ["Mac OS X"] && "display: block") || "display: none"}
          >
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              Step 3: Run this command:
            </h3>

            <.code_block multiline={true} value={unix_cmd(@token)} />
            <div class="mt-2 flex justify-between">
              <p class="text-xs text-gray-500 dark:text-gray-400">
                WireGuard <strong>not</strong>
                required! All you need is <code class="text-gray-900 dark:text-white">curl</code>, <code class="text-gray-900 dark:text-white">base64</code>,
                and <code class="text-gray-900 dark:text-white">nc</code>.
              </p>
              <.link
                navigate="https://github.com/firezone/probe/tree/main/priv/static/scripts/unix.sh"
                target="_blank"
                class="text-xs text-blue-600 dark:text-blue-400 underline hover:no-underline"
              >
                View script source
              </.link>
            </div>
          </div>

          <div
            id="windows-instructions"
            style={(@os in ["Windows"] && "display: block") || "display: none"}
          >
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              Step 3: Run this command:
            </h3>

            <.code_block multiline={true} value={windows_cmd(@token)} />
            <div class="mt-2 flex justify-between">
              <p class="text-xs text-gray-500 dark:text-gray-400">
                WireGuard <strong>not</strong>
                required! All you need is <.link
                  navigate="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
                  class="text-blue-600 dark:text-blue-400 underline hover:no-underline"
                  target="_blank"
                >Windows Powershell</.link>.
              </p>
              <.link
                navigate="https://github.com/firezone/probe/tree/main/priv/static/scripts/windows.ps1"
                target="_blank"
                class="text-xs text-blue-600 dark:text-blue-400 underline hover:no-underline"
              >
                View script source
              </.link>
            </div>
          </div>

          <div
            id="linux-instructions"
            style={(@os in ["Linux", "FreeBSD", "OpenBSD"] && "display: block") || "display: none"}
          >
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              Step 3: Run this command:
            </h3>

            <.code_block multiline={true} value={unix_cmd(@token)} />
            <div class="mt-2 flex justify-between">
              <p class="text-xs text-gray-500 dark:text-gray-400">
                WireGuard <strong>not</strong>
                required! All you need is <code class="text-gray-900 dark:text-white">curl</code>, <code class="text-gray-900 dark:text-white">base64</code>,
                and <code class="text-gray-900 dark:text-white">nc</code>.
              </p>
              <.link
                navigate="https://github.com/firezone/probe/tree/main/priv/static/scripts/unix.sh"
                target="_blank"
                class="text-xs text-blue-600 dark:text-blue-400 underline hover:no-underline"
              >
                View script source
              </.link>
            </div>
          </div>

          <div class="mt-8">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              Step 4: See the results:
            </h3>

            <p class="pb-2 text-sm text-gray-500 dark:text-gray-400">
              The section below will update in real-time as the test progresses.
            </p>

            <hr />

            <div class="py-8">
              <pre class="rounded-lg bg-gray-900 dark:bg-gray-200 text-gray-200 dark:text-gray-900 p-6"><%= @status %></pre>

              <div class="mt-8 relative overflow-x-auto">
                <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
                    <tr>
                      <th scope="col" class="w-3/12 px-4 py-3">
                        Message Type
                      </th>
                      <th scope="col" class="w-1/12 px-4 py-3">
                        Header
                      </th>
                      <th scope="col" class="w-4/12 px-4 py-3">
                        Description
                      </th>
                      <th
                        title="Vanilla WireGuard packets without any modifications"
                        scope="col"
                        class="w-1/12 text-center underline decoration-dashed px-4 py-3"
                      >
                        Plain
                      </th>
                      <th
                        title="WireGuard packets encoded by Firezone"
                        scope="col"
                        class="w-2/12 text-center underline decoration-dashed px-4 py-3"
                      >
                        Encoded
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    <.check_row
                      type="Handshake initiation"
                      header="0x01"
                      description="First message to initiate a tunnel"
                      status={get_in(@run.checks.handshake_initiation)}
                      turn_status={get_in(@run.checks.turn_handshake_initiation)}
                    />
                    <.check_row
                      type="Handshake response"
                      header="0x02"
                      description="Reply to the handshake initiation message"
                      status={get_in(@run.checks.handshake_response)}
                      turn_status={get_in(@run.checks.turn_handshake_response)}
                    />
                    <.check_row
                      type="Cookie reply"
                      header="0x03"
                      description="Used to mitigate DoS attacks"
                      status={get_in(@run.checks.cookie_reply)}
                      turn_status={get_in(@run.checks.turn_cookie_reply)}
                    />
                    <.check_row
                      type="Data message"
                      header="0x04"
                      description="The encrypted payload used to transport application data"
                      status={get_in(@run.checks.data_message)}
                      turn_status={get_in(@run.checks.turn_data_message)}
                    />
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        <% else %>
          <p class="text-2xl font-bold text-gray-900 dark:text-white">
            Waiting on WebSocket connection...
          </p>
        <% end %>
      <% else %>
        <div class="block">
          <p class="text-xl font-bold text-gray-900 dark:text-white">
            <%= @os || "Your OS" %> is not supported. Try
            <.link
              navigate={~p"/stats"}
              class="text-blue-600 dark:text-blue-400 underline hover:no-underline"
            >
              viewing the results
            </.link>
            instead.
          </p>
          <p class="text-base text-gray-500 dark:text-gray-400 mt-2">
            Want it supported? Let us know by
            <.link
              class="text-blue-600 dark:text-blue-400 underline hover:no-underline"
              navigate="https://www.github.com/firezone/probe/issues/new"
              target="_blank"
            >
              opening a GitHub issue!
            </.link>
          </p>
        </div>
      <% end %>
    </div>
    """
  end

  defp unix_cmd(token) do
    ~s"""
    sh <(curl -fsSL "#{url(~p"/scripts/unix.sh")}") \\
    #{url(~p"/runs/#{token}")}\
    """
  end

  defp windows_cmd(token) do
    ~s"""
    powershell -command "& { $`start_url='#{url(~p"/runs/#{token}")}'; iwr -useb '#{url(~p"/scripts/windows.ps1")}' | iex }"
    """
  end

  def show_macos(js \\ %JS{}) do
    js
    |> JS.show(to: "#macos-instructions")
    |> JS.hide(to: "#windows-instructions")
    |> JS.hide(to: "#linux-instructions")
    |> JS.remove_class("dark:bg-gray-800 text-gray-900", to: "#macos-btn")
    |> JS.add_class("dark:bg-gray-700 text-blue-700", to: "#macos-btn")
    |> JS.remove_class("dark:bg-gray-700 text-blue-700", to: "#windows-btn")
    |> JS.add_class("dark:bg-gray-800 text-gray-900", to: "#windows-btn")
    |> JS.remove_class("dark:bg-gray-700 text-blue-700", to: "#linux-btn")
    |> JS.add_class("dark:bg-gray-800 text-gray-900", to: "#linux-btn")
  end

  def show_windows(js \\ %JS{}) do
    js
    |> JS.hide(to: "#macos-instructions")
    |> JS.show(to: "#windows-instructions")
    |> JS.hide(to: "#linux-instructions")
    |> JS.remove_class("dark:bg-gray-700 text-blue-700", to: "#macos-btn")
    |> JS.add_class("dark:bg-gray-800 text-gray-900", to: "#macos-btn")
    |> JS.remove_class("dark:bg-gray-800 text-gray-900", to: "#windows-btn")
    |> JS.add_class("dark:bg-gray-700 text-blue-700", to: "#windows-btn")
    |> JS.remove_class("dark:bg-gray-700 text-blue-700", to: "#linux-btn")
    |> JS.add_class("dark:bg-gray-800 text-gray-900", to: "#linux-btn")
  end

  def show_linux(js \\ %JS{}) do
    js
    |> JS.hide(to: "#macos-instructions")
    |> JS.hide(to: "#windows-instructions")
    |> JS.show(to: "#linux-instructions")
    |> JS.remove_class("dark:bg-gray-700 text-blue-700", to: "#macos-btn")
    |> JS.add_class("dark:bg-gray-800 text-gray-900", to: "#macos-btn")
    |> JS.remove_class("dark:bg-gray-700 text-blue-700", to: "#windows-btn")
    |> JS.add_class("dark:bg-gray-800 text-gray-900", to: "#windows-btn")
    |> JS.remove_class("dark:bg-gray-800 text-gray-900", to: "#linux-btn")
    |> JS.add_class("dark:bg-gray-700 text-blue-700", to: "#linux-btn")
  end

  defp selected_class(nil, _), do: "dark:bg-gray-800 text-gray-900"

  defp selected_class(os, match_selected) do
    if os =~ match_selected do
      "dark:bg-gray-700 text-blue-700"
    else
      "dark:bg-gray-800 text-gray-900"
    end
  end
end
