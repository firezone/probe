defmodule Probe.Live.Component.Run do
  use Probe, :live_component

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-lg mx-auto">
      <h1 class="text-2xl font-bold text-gray-800 dark:text-gray-200">Run test</h1>
      <p class="text-gray-600 dark:text-gray-400">This is the Run section</p>
    </div>
    """
  end
end
