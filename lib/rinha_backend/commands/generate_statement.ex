defmodule RinhaBackend.Commands.GenerateStatement do
  @moduledoc false

  alias RinhaBackend.Models.{
    Client,
    Transaction
  }

  import Ecto.Query

  @app :rinha_backend

  def execute(client_id) do
    case sanitize_client_id(client_id) do
      {:ok, id} ->
        do_execute(id)

      error ->
        error
    end
  end

  def do_execute(client_id) do
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

    case repo().one(query) do
      nil -> {:error, :client_not_found}
      client -> {:ok, client}
    end
  end

  defp sanitize_client_id(client_id) when is_integer(client_id), do: {:ok, client_id}

  defp sanitize_client_id(client_id) do
    case Integer.parse(client_id) do
      {id, _} -> {:ok, id}
      :error -> {:error, :invalid_client_id}
    end
  end

  defp repo do
    @app
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:repo)
  end
end
