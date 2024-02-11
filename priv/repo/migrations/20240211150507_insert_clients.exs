defmodule RinhaBackend.Repo.Migrations.InsertClients do
  use Ecto.Migration

  def change do
    execute("""
      INSERT INTO clients (id, credit_limit, balance)
      VALUES
        (1, 100000, 0),
        (2, 80000, 0),
        (3, 1000000, 0),
        (4, 10000000, 0),
        (5, 500000, 0)
    """)
  end
end
