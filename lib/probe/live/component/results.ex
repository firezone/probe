defmodule Probe.Live.Component.Results do
  use Probe, :live_component
  alias Probe.Stats

  def mount(socket) do
    if connected?(socket) do
      stats = Stats.country_stats()
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
          Global WireGuard connectivity results
        </h1>
      </div>
      <div class="flex w-full justify-center mb-8">
        <div class="inline-flex rounded-md shadow-sm" role="group">
          <button phx-target={@myself} phx-click={show_map()} id="map-btn" type="button" class={~w[
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
              dark:bg-gray-700
              text-blue-700
            ]}>
            <.icon name="hero-globe-americas-solid" class="w-5 h-5 me-2" /> Map
          </button>
          <button phx-target={@myself} phx-click={show_list()} id="list-btn" type="button" class={~w[
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
              dark:bg-gray-800
              text-gray-900
            ]}>
            <.icon name="hero-list-bullet" class="w-5 h-5 me-2" /> List
          </button>
        </div>
      </div>

      <%= if @stats do %>
        <div id="results-map">
          <.results_map stats={@stats} />
        </div>

        <div id="results-list" class="hidden">
          <.results_table stats={@stats} />
        </div>
      <% else %>
        <div class="flex justify-center">
          <p class="text-gray-500 dark:text-gray-400">Loading...</p>
        </div>
      <% end %>
    </div>
    """
  end

  def show_map(js \\ %JS{}) do
    js
    |> JS.show(to: "#results-map")
    |> JS.hide(to: "#results-list")
    |> JS.toggle_class(
      "dark:bg-gray-700 text-blue-700 dark:bg-gray-800 text-gray-900",
      to: "#list-btn"
    )
    |> JS.toggle_class(
      "dark:bg-gray-700 text-blue-700 dark:bg-gray-800 text-gray-900",
      to: "#map-btn"
    )
  end

  def show_list(js \\ %JS{}) do
    js
    |> JS.show(to: "#results-list")
    |> JS.hide(to: "#results-map")
    |> JS.toggle_class(
      "dark:bg-gray-700 text-blue-700 dark:bg-gray-800 text-gray-900",
      to: "#list-btn"
    )
    |> JS.toggle_class(
      "dark:bg-gray-700 text-blue-700 dark:bg-gray-800 text-gray-900",
      to: "#map-btn"
    )
  end
end
