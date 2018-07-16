defmodule Octopus.Repo.Migrations.CreateUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :activated, :boolean, default: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
