defmodule Octopus.Accounts.User do
  @moduledoc """
  Defines the elements and validations for a User.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :name, :string
    field :activated, :boolean, default: false

    timestamps()
  end

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
