defmodule OctopusWeb.Plugs.AuthenticateTest do
  @moduledoc false
  use OctopusWeb.ConnCase
  use Phoenix.ConnTest
  alias OctopusWeb.Plugs.Authenticate

  defp set_format(conn) do
    params = Map.put(conn.params, "_format", "json")
    %{conn | params: params}
  end

  defp build_test_conn do
    build_conn()
    |> fetch_query_params()
    |> set_format()
  end

  test "user is restricted if they are not signed in" do
    conn = build_test_conn() |> Authenticate.call(%{})
    assert json_response(conn, 401)["errors"] != %{}
  end

  test "user is allowed through if they are signed in" do
    conn = build_test_conn() |> assign(:user_id, 1)
    plugged_conn = Authenticate.call(conn, %{})
    assert conn == plugged_conn
  end
end
