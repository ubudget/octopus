defmodule OctopusWeb.SessionViewTest do
  @moduledoc false
  use OctopusWeb.ConnCase
  import Octopus.Factory

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders show.json" do
    user = insert(:user)
    session = insert(:session, user: user)

    assert render(OctopusWeb.SessionView, "show.json", session: session) ==
             %{data: %{secure_hash: session.secure_hash}}
  end
end
