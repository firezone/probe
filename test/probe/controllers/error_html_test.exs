defmodule Probe.Controllers.ErrorHTMLTest do
  use Probe.ConnCase, async: true
  alias Probe.Controllers.ErrorHTML
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(ErrorHTML, "404", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
