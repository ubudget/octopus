defmodule Octopus.Accounts.AuthRequest do
  @moduledoc """
  Defines the fields of an auth request.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Octopus.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "auth_requests" do
    field :secure_hash, :string
    field :token, :string
    field :ip, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(auth_request, attrs) do
    auth_request
    |> cast(attrs, [:secure_hash, :token, :ip, :user_id])
    |> validate_required([:secure_hash, :token, :ip, :user_id])
  end
end
