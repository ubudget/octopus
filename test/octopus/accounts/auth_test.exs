defmodule Octopus.AuthTest do
  @moduledoc false
  use Octopus.DataCase
  use Phoenix.ConnTest
  alias Octopus.Accounts.{Auth, AuthRequest, Session, User}
  alias OctopusWeb.Endpoint
  alias Phoenix.Token
  import Octopus.Factory

  setup do
    [
      conn: build_conn(),
      user: insert(:user),
    ]
  end

  defp verify(%AuthRequest{} = req) do
    salt = Application.fetch_env!(:octopus, :auth_request_salt)
    max_age = Application.fetch_env!(:octopus, :auth_request_expiry)
    Token.verify(Endpoint, salt, req.token, max_age: max_age)
  end

  defp verify(%Session{} = session) do
    salt = Application.fetch_env!(:octopus, :session_salt)
    max_age = Application.fetch_env!(:octopus, :session_expiry)
    Token.verify(Endpoint, salt, session.token, max_age: max_age)
  end

  describe "requests" do
    def request_fixture(%{conn: conn, user: user}) do
      {:ok, %AuthRequest{} = req} = Auth.create_auth_request(conn, user)
      Repo.preload(req, :user)
    end

    test "create_auth_request creates a valid request", %{conn: conn, user: user} do
      assert {:ok, %AuthRequest{} = req} = Auth.create_auth_request(conn, user)
      assert verify(req) == {:ok, user.id}
    end

    # TODO: review if testing rejection of invalid Plug.Conn is necessary

    test "create_auth_request rejects invalid user", %{conn: conn} do
      assert {:error, %Ecto.Changeset{}} =
        Auth.create_auth_request(conn, %User{})
    end

    test "get_auth_request! returns a req with the given secure hash", c do
      req = request_fixture(c)
      assert Auth.get_auth_request!(req.secure_hash) == req
    end

    test "verify validates a live token", c do
      req = request_fixture(c)
      assert Auth.verify(req) == {:ok, req.user.id}
    end

    test "verify rejects an expired token", c do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :auth_request_expiry)
      Application.put_env(:octopus, :auth_request_expiry, -1)

      req = request_fixture(c)
      assert Auth.verify(req) == {:error, :expired}

      Application.put_env(:octopus, :auth_request_expiry, expiry)
    end

    test "delete/1 deletes a request", c do
      req = request_fixture(c)
      assert {:ok, req} = Auth.delete(req)
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_auth_request!(req.secure_hash)
      end
    end

    test "delete_expired_auth_requests prunes expired requests", c do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :auth_request_expiry)
      Application.put_env(:octopus, :auth_request_expiry, -1)

      req = request_fixture(c)
      :ok = Auth.delete_expired_auth_requests()
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_auth_request!(req.secure_hash)
      end

      Application.put_env(:octopus, :auth_request_expiry, expiry)
    end
  end

  describe "sessions" do
    def session_fixture(%{conn: conn, user: user}) do
      {:ok, %Session{} = session} = Auth.create_session(conn, user)
      Repo.preload(session, :user)
    end

    test "create_session creates a valid session", %{conn: conn, user: user} do
      assert {:ok, %Session{} = session} = Auth.create_session(conn, user)
      assert verify(session) == {:ok, user.id}
    end

    # TODO: review if testing rejection of invalid Plug.Conn is necessary

    test "create_session rejects invalid user", %{conn: conn} do
      assert {:error, %Ecto.Changeset{}} =
        Auth.create_session(conn, %User{})
    end

    test "get_session! returns a session with the given secure hash", c do
      session = session_fixture(c)
      assert Auth.get_session!(session.secure_hash) == session
    end

    test "verify validates a live token", c do
      session = session_fixture(c)
      assert Auth.verify(session) == {:ok, session.user.id}
    end

    test "verify rejects an expired token", c do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :session_expiry)
      Application.put_env(:octopus, :session_expiry, -1)

      session = session_fixture(c)
      assert Auth.verify(session) == {:error, :expired}

      Application.put_env(:octopus, :session_expiry, expiry)
    end

    test "extend_session extends a session in the valid age range", c do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :refresh_expiry_interval)
      Application.put_env(:octopus, :refresh_expiry_interval, -1)

      %{token: token} = session = session_fixture(c)
      assert {:ok, session} = Auth.extend_session(session)
      assert token != session.token

      Application.put_env(:octopus, :refresh_expiry_interval, expiry)
    end

    test "extend_session ignores a session that is too young", c do
      %{token: token} = session = session_fixture(c)
      assert is_nil(Auth.extend_session(session))
      assert token == session.token
    end

    test "delete/1 deletes a session", c do
      session = session_fixture(c)
      assert {:ok, session} = Auth.delete(session)
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end
    end

    test "delete_expired_sessions prunes expired session", c do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :session_expiry)
      Application.put_env(:octopus, :session_expiry, -1)

      session = session_fixture(c)
      :ok = Auth.delete_expired_sessions()
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end

      Application.put_env(:octopus, :session_expiry, expiry)
    end

    test "delete_session! deletes a session by unique hash", c do
      session = session_fixture(c)
      assert {:ok, session} = Auth.delete_session!(session.secure_hash)
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end
    end
  end
end
