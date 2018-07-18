defmodule OctopusWeb.ChangesetViewTest do
  @moduledoc false
  use OctopusWeb.ConnCase, async: true
  alias Octopus.Accounts
  alias Octopus.Accounts.User

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders changeset error" do
    user_changeset = Accounts.change_user(%User{})
    assert render(
      OctopusWeb.ChangesetView,
      "error.json",
      changeset: user_changeset
    ) == %{errors: %{email: ["can't be blank"]}}
  end
end
