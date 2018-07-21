defmodule OctopusWeb.UserControllerTest do
  @moduledoc false
  use OctopusWeb.ConnCase
  alias Octopus.Accounts
  alias Octopus.Accounts.{Request, User}
  alias Octopus.{Repo, Secure}
  alias OctopusWeb.Router.Helpers
  alias OctopusWeb.UserEmail
  alias Phoenix.Controller
  import Octopus.Factory
  import Swoosh.TestAssertions

  setup %{conn: conn} do
    [conn: put_req_header(conn, "accept", "application/json")]
  end

  setup do
    [user: insert(:user)]
  end

  @valid_attrs %{email: "jqt@email.com", name: "John Q. Test"}
  @update_attrs %{email: "jqt@email.net", name: "JQT"}
  @invalid_attrs %{email: "invalid"}

  defp build_url(conn, req) do
    uri = Controller.endpoint_module(conn).struct_url()
    path = Helpers.session_path(conn, :create, secure_hash: req.secure_hash)
    Helpers.url(uri) <> path
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @valid_attrs)
      assert %{"ok" => true} = json_response(conn, 200)

      req = Repo.get_by(Request, ip: Secure.get_user_ip(conn))

      assert %User{} = user = Accounts.get_user_by_email("jqt@email.com")
      assert user.name == "John Q. Test"
      assert_email_sent(UserEmail.registration(user, build_url(conn, req)))
    end

    test "nop if user already exists", %{conn: conn, user: user} do
      {:ok, user} = Accounts.activate_user(user)
      conn = post(conn, user_path(conn, :create), user: Map.from_struct(user))
      assert %{"ok" => true} = json_response(conn, 200)

      req = Repo.get_by(Request, ip: Secure.get_user_ip(conn))

      assert Accounts.get_user!(user.id) == user
      assert_email_sent(UserEmail.signin(user, build_url(conn, req)))
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
      assert_no_email_sent()
    end
  end

  describe "update user" do
    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      req = Repo.get_by(Request, ip: Secure.get_user_ip(conn))

      assert %User{} = user = Accounts.get_user!(id)
      assert user.name == "JQT"
      assert user.email == "jqt@email.net"
      refute user.activated
      assert_email_sent(UserEmail.reactivate(user, build_url(conn, req)))
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end
    end
  end
end
