defmodule Octopus.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Octopus.Accounts.User
  alias Octopus.Repo

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
  Gets a user by email.
  """
  def get_user_by_email(email), do: Repo.get_by(User, email: email |> String.downcase())

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
  def activate_user(%User{} = user) do
    unless user.activated, do: user |> update_user(%{activated: true})
  end

  @doc """
  Mark a user as deactivated to handle changed emails.
  """
  def deactivate_user(%User{} = user) do
    if user.activated, do: user |> update_user(%{activated: false})
  end

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
  Deletes unactivated or deactivated Users.
  """
  def delete_unactivated_users, do: User.unactivated() |> Repo.delete_all()

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
