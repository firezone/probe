defmodule Probe.Controllers.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use Probe, :html

  def render("500.html", _assigns) do
    case Sentry.get_last_event_id_and_source() do
      {event_id, :plug} when is_binary(event_id) ->
        opts = Jason.encode!(%{eventId: event_id})
        assigns = %{opts: opts}

        ~H"""
        <script
          src="https://browser.sentry-cdn.com/5.9.1/bundle.min.js"
          integrity="sha384-/x1aHz0nKRd6zVUazsV6CbQvjJvr6zQL2CHbQZf3yoLkezyEtZUpqUNnOLW9Nt3v"
          crossorigin="anonymous"
        >
        </script>
        <script>
          Sentry.init({ dsn: '<%= Sentry.Config.dsn() %>' });
          Sentry.showReportDialog(<%= @opts %>)
        </script>
        """

      _ ->
        "Internal Server Error"
    end
  end

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/probe/controllers/error_html/404.html.heex
  #   * lib/probe/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
