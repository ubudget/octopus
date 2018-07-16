defmodule Octopus.Repo.Migrations.CreateAuthRequests do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:auth_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :secure_hash, :string
      add :token, :string
      add :ip, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:auth_requests, [:user_id])
  end
end
