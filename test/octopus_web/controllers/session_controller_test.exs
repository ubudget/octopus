defmodule OctopusWeb.SessionControllerTest do
  @moduledoc false
  use OctopusWeb.ConnCase
  import Octopus.Factory
  alias Octopus.Accounts.{Auth, Session}

  setup %{conn: conn} do
    [conn: put_req_header(conn, "accept", "application/json")]
  end

  setup do
    user = insert(:user)

    [
      user: user,
      request: request_with_token(user),
      session: session_with_token(user)
    ]
  end

  describe "create session" do
    test "renders session when data is valid", %{conn: conn, request: request} do
      conn = post(conn, session_path(conn, :create), request: request.secure_hash)

      assert %{"secure_hash" => secure_hash} = json_response(conn, 200)["data"]

      assert %Session{} = session = Auth.get_session!(secure_hash)
      assert session.user.id == request.user.id
      assert Auth.verify(session) == {:ok, session.user.id}
      assert session.user.activated

      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_request!(request.secure_hash)
      end
    end

    test "renders error when data is invalid", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), request: "invalid-hash")
      assert %{} != json_response(conn, 404)["errors"]
    end
  end

  describe "delete session" do
    test "deletes specified session", %{conn: conn, session: session} do
      conn = delete(conn, session_path(conn, :delete, session.secure_hash))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end
    end
  end
end
