defmodule Octopus.Accounts.Auth do
  @moduledoc """
  Context for auth related flows.
  """
  import Ecto.Query, warn: false
  alias Octopus.Accounts.{Request, Session, User}
  alias Octopus.Repo
  alias Octopus.Secure
  alias OctopusWeb.Endpoint
  alias Phoenix.Token

  defp request_salt, do: Application.fetch_env!(:octopus, :request_salt)
  defp session_salt, do: Application.fetch_env!(:octopus, :session_salt)

  @doc """
  Creates an auth request.
  """
  def create_request(conn, %User{} = user) do
    token = Token.sign(Endpoint, request_salt(), user.id)
    secure_hash = Secure.generate_hash(conn)

    %Request{}
    |> Request.changeset(%{
      secure_hash: secure_hash,
      token: token,
      ip: Secure.get_user_ip(conn),
      user_id: user.id,
    })
    |> Repo.insert()
  end

  @doc """
  Returns an auth request by its unique secure hash.

  Raises `Ecto.NoResultsError` if the Request does not exist.
  """
  def get_request!(secure_hash) do
    Request
    |> Repo.get_by!(secure_hash: secure_hash)
    |> Repo.preload(:user)
  end

  @doc """
  Returns a resuest by its unique secure hash, or nil.
  """
  def get_request(secure_hash) do
    if request = Request
                 |> Repo.get_by(secure_hash: secure_hash)
                 |> Repo.preload(:user) do
      {:ok, request}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Verify that the token in the specified auth request or session is valid.
  """
  def verify(%Request{token: token}) do
    max_age = Application.fetch_env!(:octopus, :request_expiry)
    Token.verify(Endpoint, request_salt(), token, max_age: max_age)
  end

  def verify(%Session{token: token}) do
    max_age = Application.fetch_env!(:octopus, :session_expiry)
    verify_session_token(token, max_age)
  end

  @doc """
  Creates a user session.
  """
  def create_session(conn, %User{} = user) do
    token = create_session_token(user.id)
    secure_hash = Secure.generate_hash(conn)

    %Session{}
    |> Session.changeset(%{
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
  def get_session!(secure_hash) do
    Session
    |> Repo.get_by!(secure_hash: secure_hash)
    |> Repo.preload(:user)
  end

  @doc """
  Returns a session by its unique secure hash, or nil.
  """
  def get_session(secure_hash) do
    if session = Session
                 |> Repo.get_by(secure_hash: secure_hash)
                 |> Repo.preload(:user) do
      {:ok, session}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Extends a session by resetting the token in the database.
  """
  def extend_session(%Session{token: token, user_id: user_id} = session) do
    # TODO: does extend_session need to ensure that a session is still valid?
    max_age = Application.fetch_env!(:octopus, :refresh_expiry_interval)
    case verify_session_token(token, max_age) do
      {:error, :expired} ->
        session
        |> Session.changeset(%{token: create_session_token(user_id)})
        |> Repo.update()
      _ ->
        nil
    end
  end

  defp create_session_token(user_id), do: Token.sign(Endpoint, session_salt(), user_id)
  defp verify_session_token(token, max_age), do: Token.verify(Endpoint, session_salt(), token, max_age: max_age)

  @doc """
  Deletes an auth request or session.
  """
  def delete(%Request{} = request), do: Repo.delete(request)

  def delete(%Session{} = session), do: Repo.delete(session)

  @doc """
  Delete a session by unique hash.
  """
  def delete_session!(secure_hash), do: secure_hash |> get_session!() |> delete()

  # TODO: look into returning information about how many deletions happened

  @doc """
  Prune expired auth requests.
  """
  def delete_expired_requests do
    Request
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
