defmodule OctopusWeb.Plugs.UserIdTest do
  @moduledoc false
  use OctopusWeb.ConnCase
  use Phoenix.ConnTest
  alias Octopus.Accounts.Auth
  alias OctopusWeb.Plugs.UserId
  import Octopus.Factory

  def set_param(conn, key, value) do
    params = Map.put(conn.params, key, value)
    %{conn | params: params}
  end

  defp build_test_conn do
    build_conn()
    |> Map.put(:assigns, %{})
    |> fetch_query_params()
    |> set_param("_format", "json")
  end

  setup do
    user = insert(:user)

    [session: session_with_token(user)]
  end

  test "ignores an unsecured conn" do
    conn = build_test_conn()
    plugged_conn = UserId.call(conn, %{})
    assert conn == plugged_conn
  end

  test "assigns to a secured conn", %{session: session} do
    conn =
      build_test_conn()
      |> set_param("session", session.secure_hash)
      |> UserId.call(%{})

    assert conn.assigns[:user_id] == session.user.id
    assert conn.assigns[:session] == session.secure_hash
  end

  @tag skip: "this will have to wait until we have a more robust task handling system"
  # to elaborate, I'm envisioning a module that can take a task as an argument
  # and schedule it to run once or routinely, with appropriate error handling
  # and logging as well as a test adapter to allow situations like this to be
  # tested via message passing
  test "an extended token is updated", %{session: session} do
    # MAJOR TODO: these config clean ups seem like something that
    # could REALLY easilybe rewritten as a test wrapper of some kind
    expiry = Application.fetch_env!(:octopus, :refresh_expiry_interval)
    Application.put_env(:octopus, :refresh_expiry_interval, -1)

    token = session.token

    conn =
      build_test_conn()
      |> set_param("session", session.secure_hash)
      |> UserId.call(%{})

    assert conn.assigns[:user_id] == session.user.id
    assert conn.assigns[:session] == session.secure_hash

    session = Auth.get_session!(session.secure_hash)
    assert session.token != token

    Application.put_env(:octopus, :refresh_expiry_interval, expiry)
  end
end
