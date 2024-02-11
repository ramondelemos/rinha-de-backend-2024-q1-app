defmodule RinhaBackend.Repo.Migrations.CreateClientsTable do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :credit_limit, :integer
      add :balance, :bigint, default: 0
    end
  end
end
