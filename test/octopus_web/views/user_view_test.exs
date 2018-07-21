defmodule OctopusWeb.UserViewTest do
  @moduledoc false
  use OctopusWeb.ConnCase
  import Octopus.Factory

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders show.json" do
    user = insert(:user)

    assert render(OctopusWeb.UserView, "show.json", user: user) ==
             %{data: %{id: user.id, name: user.name, email: user.email}}
  end

  test "renders ok.json" do
    assert render(OctopusWeb.UserView, "ok.json", []) == %{ok: true}
  end
end
