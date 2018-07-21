defmodule Octopus.Repo.Migrations.CreateAuthRequests do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :secure_hash, :string
      add :token, :string
      add :ip, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:requests, [:user_id])
    create index(:requests, [:secure_hash])
  end
end
