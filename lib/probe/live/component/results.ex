defmodule Probe.Live.Component.Results do
  use Probe, :live_component

  @results [
    %{country_code: "us", rate: 0.986, num: 100},
    %{country_code: "ca", rate: 0.987, num: 100}
  ]

  def mount(socket) do
    {:ok, assign(socket, :results, @results)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-lg mx-auto">
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

      <div id="results-map">
        <.results_map results={@results} />
      </div>

      <div id="results-list" class="hidden">
        <.results_table results={@results} />
      </div>
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