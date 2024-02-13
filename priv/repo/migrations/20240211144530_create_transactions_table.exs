defmodule RinhaBackend.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :client_id, :integer
      add :value, :bigint
      add :type, :string
      add :description, :string

      timestamps(type: :naive_datetime_usec, updated_at: false)
    end

    create(index(:transactions, [:client_id, :inserted_at]))
  end
end
