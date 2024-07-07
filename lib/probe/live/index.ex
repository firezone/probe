defmodule Probe.Live.Index do
  use Probe, :live_view

  def render(assigns) do
    ~H"""
    <div class="antialiased bg-gray-50 dark:bg-gray-900">
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
