defmodule Probe.ListComponents do
  use Phoenix.Component

  def results_table(assigns) do
    ~H"""
    <div class="relative overflow-x-auto">
      <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="px-6 py-3">
              Country
            </th>
            <th scope="col" class="px-6 py-3">
              Number of tests
            </th>
            <th scope="col" class="px-6 py-3">
              Success Rate
            </th>
          </tr>
        </thead>
        <tbody>
          <%= for %{country_code: country_code, rate: rate, num: num} <- @results do %>
            <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
              <td class="px-6 py-4 whitespace-nowrap dark:text-white">
                <%= country_code %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap dark:text-white">
                <%= num %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap dark:text-white">
                <%= rate %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
