defmodule Octopus.Accounts.Session do
  @moduledoc """
  Defines the fields needed to handle session creation and deletion.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Octopus.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    field :secure_hash, :string
    field :token, :string
    field :ip, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:secure_hash, :token, :ip, :user_id])
    |> validate_required([:secure_hash, :token, :ip, :user_id])
  end
end
