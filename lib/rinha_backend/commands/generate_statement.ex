defmodule RinhaBackend.Commands.GenerateStatement do
  @moduledoc false

  alias RinhaBackend.Models.{
    Client,
    Transaction
  }

  alias RinhaBackend.Repo

  import Ecto.Query

  def execute(client_id) do
    transactions_query =
      from(t in Transaction,
        where: t.client_id == ^client_id,
        order_by: [desc: t.inserted_at],
        limit: 10
      )

    query =
      from(c in Client,
        where: c.id == ^client_id,
        preload: [transactions: ^transactions_query]
      )

    case Repo.one(query) do
      nil -> {:error, :client_not_found}
      client -> {:ok, client}
    end
  end
end
