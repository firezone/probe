defmodule Probe.ListComponents do
  use Phoenix.Component

  attr :stats, :list

  def stats_table(assigns) do
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
          <%= for stat <- @stats do %>
            <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
              <td class="px-6 py-4 whitespace-nowrap dark:text-white">
                <%= stat.country %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap dark:text-white">
                <%= stat.num_completed %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap dark:text-white">
                <%= :erlang.float_to_binary(stat.num_succeeded * 100 / stat.num_completed,
                  decimals: 2
                ) %>%
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
