defmodule Probe.Live.Index do
  use Probe, :live_view

  def render(assigns) do
    ~H"""
    <div class="antialiased bg-gray-50 dark:bg-gray-900">
      <div class="absolute right-0 top-0 p-4">
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

      <div class="items-center justify-center bg-gray-50 dark:bg-gray-900 py-5 flex">
        <nav
          id="toggleMobileMenu"
          class="bg-gray-50 border-b border-gray-200 dark:bg-gray-900 block mx-auto dark:border-gray-800"
        >
          <div class="flex items-center">
            <ul class="flex flex-row mt-0 w-full text-sm font-medium">
              <li class="inline dark:border-gray-700 border-b-0">
                <.link navigate="/" class={tab_class(@live_action, :run)}>
                  Run test
                </.link>
              </li>
              <li class="inline dark:border-gray-700 border-b-0">
                <.link navigate="/results" class={tab_class(@live_action, :results)}>
                  View results
                </.link>
              </li>
              <li class="inline dark:border-gray-700 border-b-0">
                <.link navigate="/faq" class={tab_class(@live_action, :faq)}>
                  FAQ
                </.link>
              </li>
            </ul>
          </div>
        </nav>
      </div>

      <main class="dark:bg-gray-900 flex-1 p-4 space-y-4">
        <%= if @live_action == :run do %>
          <.live_component module={Probe.Live.Component.Run} id="run" />
        <% end %>
        <%= if @live_action == :results do %>
          <.live_component module={Probe.Live.Component.Results} id="results" />
        <% end %>
        <%= if @live_action == :faq do %>
          <.live_component module={Probe.Live.Component.Faq} id="faq" />
        <% end %>
      </main>

      <footer></footer>
    </div>
    """
  end

  defp tab_class(live_action, action) do
    common = "block py-3 px-4"

    if live_action == action do
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
end
