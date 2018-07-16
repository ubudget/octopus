defmodule Octopus.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Octopus.Accounts.User
  alias Octopus.Repo

  def auth_request_salt, do: Application.fetch_env!(:octopus, :auth_request_salt)
  def session_salt, do: Application.fetch_env!(:octopus, :session_salt)

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Mark a user as activated.
  """
  def activate_user(%User{} = user), do: update_user(user, %{activated: true})

  @doc """
  Mark a user as deactivated to handle changed emails.
  """
  def deactivate_user(%User{} = user), do: update_user(user, %{activated: false})

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
