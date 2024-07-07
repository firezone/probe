defmodule Probe.Live.Component.Faq do
  use Probe, :live_component

  def render(assigns) do
    ~H"""
    <div class="border-2 border-dashed border-gray-300 flex-1 rounded-xl dark:border-gray-600 h-96">
      <h1 class="text-2xl font-bold text-gray-800 dark:text-gray-200">FAQ</h1>
      <p class="text-gray-600 dark:text-gray-400">This is the FAQ section</p>
    </div>
    """
  end
end
