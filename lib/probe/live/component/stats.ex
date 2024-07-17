defmodule Probe.Live.Component.Results do
  use Probe, :live_component
  alias Probe.Runs

  def mount(socket) do
    if connected?(socket) do
      stats = Runs.country_stats()
      {:ok, assign(socket, :stats, stats)}
    else
      {:ok, assign(socket, :stats, nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-xl mx-auto">
      <div class="flex justify-center mb-8">
        <h1 class="text-4xl font-bold text-gray-800 dark:text-gray-200">
          Global WireGuard connectivity statistics
        </h1>
      </div>
      <div class="flex w-full justify-center mb-8">
        <div class="inline-flex rounded-md shadow-sm" role="group">
          <.link navigate={~p"/stats/map"} class={~w[
              inline-flex
              items-center
              px-4
              py-2
              text-sm
              font-medium
              bg-white
              border-t
              border-l
              border-b
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
              #{(@tab == :stats_map && "dark:bg-gray-700 text-blue-700") || "dark:bg-gray-800 text-gray-900"}
            ]}>
            <.icon name="hero-globe-americas-solid" class="w-5 h-5 me-2" /> Map
          </.link>
          <.link navigate={~p"/stats/list"} class={~w[
              inline-flex
              items-center
              px-4
              py-2
              text-sm
              font-medium
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
              #{(@tab == :stats_list && "dark:bg-gray-700 text-blue-700") || "dark:bg-gray-800 text-gray-900"}
            ]}>
            <.icon name="hero-list-bullet" class="w-5 h-5 me-2" /> List
          </.link>
        </div>
      </div>

      <%= if @stats do %>
        <div :if={@tab == :stats_map} id="stats-map">
          <.stats_map stats={@stats} />
        </div>

        <div :if={@tab == :stats_list} id="stats-list">
          <.stats_table stats={@stats} />
        </div>
      <% else %>
        <div class="flex justify-center">
          <p class="text-gray-500 dark:text-gray-400">Loading...</p>
        </div>
      <% end %>
    </div>
    """
  end
end
