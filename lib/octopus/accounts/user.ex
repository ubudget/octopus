defmodule Octopus.Accounts.User do
  @moduledoc """
  Defines the elements and validations for a User.
  """
  # TODO: clean up Veil associations if not necessary
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  # alias Octopus.Accounts.{AuthRequest, Session}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :name, :string
    field :activated, :boolean, default: false

    # has_many :auth_requests, AuthRequest
    # has_many :sessions, Session

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, min: 1, max: 16)
    # Taken from https://stackoverflow.com/a/742588
    |> validate_format(:email, ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/)
    |> make_email_lowercase()
    |> unique_constraint(:email)
  end

  @doc false
  def activate_changeset(user, activated), do: user |> change(%{activated: activated})

  def unactivated(query \\ __MODULE__) do
    from u in query,
    where: u.activated == false
  end

  defp make_email_lowercase(%Ecto.Changeset{
    valid?: true,
    changes: %{email: email},
  } = changeset) do
    put_change(changeset, :email, email |> String.downcase())
  end

  defp make_email_lowercase(changeset), do: changeset
end
