defmodule RinhaBackend.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :client_id, :integer
      add :value, :bigint
      add :type, :string
      add :description, :string
    end
  end
end
