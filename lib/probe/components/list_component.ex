defmodule Probe.ListComponent do
  use Phoenix.Component

  def list(assigns) do
    ~H"""
    <ul>
      <%= for item <- @items do %>
        <li><%= item %></li>
      <% end %>
    </ul>
    """
  end
end
