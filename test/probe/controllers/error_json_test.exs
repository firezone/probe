defmodule Probe.ErrorJSONTest do
  use Probe.ConnCase, async: true
  import Probe.Controllers.ErrorJSON

  test "renders 404" do
    assert render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert render("500.json", %{}) == %{errors: %{detail: "Internal Server Error"}}
  end
end
