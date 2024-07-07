defmodule Probe.Live.Component.Faq do
  use Probe, :live_component

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-lg mx-auto">
      <h1 class="text-2xl font-bold text-gray-800 dark:text-gray-200">FAQ</h1>
      <p class="text-gray-600 dark:text-gray-400">This is the FAQ section</p>

      <blockquote class="mt-8">
        <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">What is Probe?</p>
        <p class="text-gray-600 dark:text-gray-400">
          Probe is a testing tool for WireGuard connections.
        </p>
      </blockquote>
    </div>
    """
  end
end
