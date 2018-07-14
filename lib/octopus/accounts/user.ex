defmodule Octopus.Accounts.User do
  @moduledoc """
  Defines basic elements of a user model and ensures validation of email and password elements.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Bcrypt


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :first_name, :string
    field :last_name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :encrypted_password])
    |> validate_required([:first_name, :last_name, :email, :encrypted_password])
    |> unique_constraint(:email)
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_password(:password)
    |> put_password_hash
  end

  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, password) ->
      case valid_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  defp valid_password?(password) do
    cond do
      String.length(password) < 10 -> {:error, "Password too short"}
      String.length(password) > 128 -> {:error, "Password too long"}
      password_score(password) < 3 -> {:error, "Password too simple"}
      true -> {:ok, password}
    end
  end

  defp password_score(password) do
    Enum.reduce([
      ~r/[a-z]+/,
      ~r/[A-Z]+/,
      ~r/[0-9]+/,
      ~r/[ !"#$%&'()*+,\-.:;<=>?@[\\\]^_`{|}~]+/
    ], 0, fn(rule, score) -> score + (if String.match?(password, rule), do: 1, else: 0) end)
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
