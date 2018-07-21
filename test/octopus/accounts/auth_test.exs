defmodule Octopus.AuthTest do
  @moduledoc false
  use Octopus.DataCase
  use Phoenix.ConnTest
  alias Octopus.Accounts.{Auth, Request, Session, User}
  alias OctopusWeb.Endpoint
  alias Phoenix.Token
  import Octopus.Factory

  setup do
    user = insert(:user)

    [request: request_with_token(user),
    session: session_with_token(user)]
  end

  defp verify(%Request{} = req) do
    salt = Application.fetch_env!(:octopus, :request_salt)
    max_age = Application.fetch_env!(:octopus, :request_expiry)
    Token.verify(Endpoint, salt, req.token, max_age: max_age)
  end

  defp verify(%Session{} = session) do
    salt = Application.fetch_env!(:octopus, :session_salt)
    max_age = Application.fetch_env!(:octopus, :session_expiry)
    Token.verify(Endpoint, salt, session.token, max_age: max_age)
  end

  describe "requests" do
    test "create_request creates a valid request" do
      conn = build_conn()
      user = insert(:user)
      assert {:ok, %Request{} = request} = Auth.create_request(conn, user)
      assert verify(request) == {:ok, user.id}
    end

    test "create_request rejects invalid user" do
      conn = build_conn()
      assert {:error, %Ecto.Changeset{}} =
        Auth.create_request(conn, %User{})
    end

    test "get_request! returns a req with the given secure hash", %{request: request} do
      assert Auth.get_request!(request.secure_hash) == request
    end

    test "verify validates a live token", %{request: request} do
      assert Auth.verify(request) == {:ok, request.user.id}
    end

    test "verify rejects an expired token", %{request: request} do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :request_expiry)
      Application.put_env(:octopus, :request_expiry, -1)

      assert Auth.verify(request) == {:error, :expired}

      Application.put_env(:octopus, :request_expiry, expiry)
    end

    test "delete/1 deletes a request", %{request: request} do
      assert {:ok, request} = Auth.delete(request)
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_request!(request.secure_hash)
      end
    end

    test "delete_expired_requests prunes expired requests", %{request: request} do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :request_expiry)
      Application.put_env(:octopus, :request_expiry, -1)

      :ok = Auth.delete_expired_requests()
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_request!(request.secure_hash)
      end

      Application.put_env(:octopus, :request_expiry, expiry)
    end
  end

  describe "sessions" do
    test "create_session creates a valid session" do
      conn = build_conn()
      user = insert(:user)
      assert {:ok, %Session{} = session} = Auth.create_session(conn, user)
      assert verify(session) == {:ok, user.id}
    end

    test "create_session rejects invalid user" do
      conn = build_conn()
      assert {:error, %Ecto.Changeset{}} =
        Auth.create_session(conn, %User{})
    end

    test "get_session! returns a session with the given secure hash", %{session: session} do
      assert Auth.get_session!(session.secure_hash) == session
    end

    test "verify validates a live token", %{session: session} do
      assert Auth.verify(session) == {:ok, session.user.id}
    end

    test "verify rejects an expired token", %{session: session} do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :session_expiry)
      Application.put_env(:octopus, :session_expiry, -1)

      assert Auth.verify(session) == {:error, :expired}

      Application.put_env(:octopus, :session_expiry, expiry)
    end

    test "extend_session extends a session in the valid age range", %{session: session} do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :refresh_expiry_interval)
      Application.put_env(:octopus, :refresh_expiry_interval, -1)

      assert {:ok, session_extended} = Auth.extend_session(session)
      assert session.token != session_extended.token

      Application.put_env(:octopus, :refresh_expiry_interval, expiry)
    end

    test "extend_session ignores a session that is too young", %{session: session}  do
      assert is_nil(Auth.extend_session(session))
      assert Auth.get_session!(session.secure_hash) == session
    end

    test "delete/1 deletes a session", %{session: session} do
      assert {:ok, session} = Auth.delete(session)
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end
    end

    test "delete_expired_sessions prunes expired session", %{session: session} do
      # TODO: refactor opportunity, expiries might need to move out of config
      expiry = Application.fetch_env!(:octopus, :session_expiry)
      Application.put_env(:octopus, :session_expiry, -1)

      :ok = Auth.delete_expired_sessions()
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end

      Application.put_env(:octopus, :session_expiry, expiry)
    end

    test "delete_session! deletes a session by unique hash", %{session: session} do
      assert {:ok, session} = Auth.delete_session!(session.secure_hash)
      assert_raise Ecto.NoResultsError, fn ->
        Auth.get_session!(session.secure_hash)
      end
    end
  end
end
