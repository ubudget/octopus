defmodule Octopus.Accounts.Auth do
  @moduledoc """
  Context for auth related flows.
  """
  import Ecto.Query, warn: false
  alias Octopus.Accounts.{AuthRequest, Session, User}
  alias Octopus.Repo
  alias Octopus.Secure
  alias Phoenix.Token

  defp auth_request_salt, do: Application.fetch_env!(:octopus, :auth_request_salt)
  defp session_salt, do: Application.fetch_env!(:octopus, :session_salt)

  @doc """
  Creates an auth request.
  """
  def create_auth_request(conn, %User{} = user) do
    token = Token.sign(conn, auth_request_salt(), user.id)
    secure_hash = Secure.generate_hash(conn)

    %AuthRequest{}
    |> AuthRequest.changeset(%{
      secure_hash: secure_hash,
      token: token,
      ip: Secure.get_user_ip(conn),
      user_id: user.id,
    })
    |> Repo.insert()
  end

  @doc """
  Returns an auth request by its unique secure hash.

  Raises `Ecto.NoResultsError` if the AuthRequest does not exist.
  """
  def get_auth_request!(secure_hash), do: Repo.get_by!(AuthRequest, secure_hash: secure_hash)

  @doc """
  Verify that the token in the specified auth request or session is valid.
  """
  def verify(%AuthRequest{} = auth_request), do: verify(OctopusWeb.Endpoint, auth_request)

  def verify(%Session{} = session), do: verify(OctopusWeb.Endpoint, session)

  def verify(conn, %AuthRequest{token: token}) do
    max_age = Application.fetch_env!(:octopus, :auth_request_expiry)
    Token.verify(conn, auth_request_salt(), token, max_age)
  end

  def verify(conn, %Session{token: token}) do
    max_age = Application.fetch_env!(:octopus, :session_expiry)
    verify_session_token(conn, token, max_age)
  end

  @doc """
  Creates a user session.
  """
  def create_session(conn, %User{} = user) do
    token = create_session_token(conn, user.id)
    secure_hash = Secure.generate_hash(conn)

    %AuthRequest{}
    |> AuthRequest.changeset(%{
      secure_hash: secure_hash,
      token: token,
      ip: Secure.get_user_ip(conn),
      user_id: user.id,
    })
    |> Repo.insert()
  end

  @doc """
  Returns a session by its unique secure hash.

  Raises `Ecto.NoResultsError` if the Session does not exist.
  """
  def get_session!(secure_hash), do: Repo.get_by!(Session, secure_hash: secure_hash)

  @doc """
  Extends a session by resetting the token in the database.
  """
  def extend_session(conn, %Session{token: token, user_id: user_id} = session) do
    max_age = Application.fetch_env!(:octopus, :refresh_expiry_interval)
    case verify_session_token(conn, token, max_age) do
      {:error, :expired} ->
        session
        |> Session.changeset(%{token: create_session_token(conn, user_id)})
        |> Repo.update()
      _ ->
        nil
    end
  end

  defp create_session_token(conn, user_id), do: Token.sign(conn, session_salt(), user_id)
  defp verify_session_token(conn, token, max_age), do: Token.verify(conn, session_salt(), token, max_age)

  @doc """
  Deletes an auth request or session.
  """
  def delete(%AuthRequest{} = auth_request), do: Repo.delete(auth_request)

  def delete(%Session{} = session), do: Repo.delete(session)

  @doc """
  Delete a session by unique hash.
  """
  def delete_session!(secure_hash), do: secure_hash |> get_session!() |> delete()

  @doc """
  Prune expired auth requests.
  """
  def delete_expired_auth_requests do
    AuthRequest
    |> Repo.all()
    |> delete_expired()
  end

  @doc """
  Prune expired sessions.
  """
  def delete_expired_sessions do
    Session
    |> Repo.all()
    |> delete_expired()
  end

  defp delete_expired(list) when is_list(list) do
    Enum.each(list, fn(record) ->
      case verify(record) do
        {:error, _} -> delete(record)
        {:ok, _} -> nil
      end
    end)
  end
end
