defmodule Probe.Live.Component.Faq do
  use Probe, :live_component

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-sm mx-auto">
      <h1 class="text-2xl font-bold text-gray-800 dark:text-gray-200">FAQ</h1>
      <p class="text-gray-600 dark:text-gray-400">
        All the things you wanted to know about Probe, and maybe even a few things you didn't.
      </p>

      <ul class="mt-8">
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">What is Probe?</p>
          <p class="text-gray-600 dark:text-gray-400">
            Probe is a testing tool for WireGuard connections.
          </p>
        </li>
      </ul>
    </div>
    """
  end
end
