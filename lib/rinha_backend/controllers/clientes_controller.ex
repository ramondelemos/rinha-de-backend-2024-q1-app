defmodule RinhaBackend.Controllers.ClientsController do
  @moduledoc false

  alias RinhaBackend.Commands.{
    GenerateStatement,
    ProcessTransaction
  }

  alias RinhaBackend.Models.{
    Client,
    Transaction
  }

  def create_transaction(id, params) do
    params
    |> translate_transaction_body()
    |> Map.put("client_id", id)
    |> Transaction.from_map()
    |> case do
      {:ok, transaction} -> do_create_transaction(transaction)
      error -> error
    end
  end

  def get_statement(id) do
    id
    |> GenerateStatement.execute()
    |> case do
      {:ok, %Client{} = client} ->
        build_statement(client)

      {:error, :client_not_found} ->
        {:error, :not_found}

      error ->
        error
    end
  end

  defp translate_transaction_body(body) do
    Enum.reduce(body, %{}, fn
      {"valor", val}, acc ->
        Map.put(acc, "value", val)

      {"tipo", val}, acc ->
        Map.put(acc, "type", val)

      {"descricao", val}, acc ->
        Map.put(acc, "description", val)

      {key, val}, acc ->
        Map.put(acc, key, val)
    end)
  end

  defp do_create_transaction(transaction) do
    case ProcessTransaction.execute(transaction) do
      {:ok, {balance, limit}} ->
        Jason.encode(%{"saldo" => balance, "limite" => limit})

      {:error, :client_not_found} ->
        {:error, :not_found}

      error ->
        error
    end
  end

  defp build_statement(%Client{balance: balance, credit_limit: limit, transactions: transactions}) do
    statement = %{
      "saldo" => %{
        "total" => balance,
        "limite" => limit,
        "data_extrato" => DateTime.to_iso8601(DateTime.utc_now())
      },
      "ultimas_transacoes" => build_transactions(transactions)
    }

    Jason.encode(statement)
  end

  defp build_transactions(transactions) do
    transactions
    |> Enum.map(&build_transaction(&1))
  end

  defp build_transaction(%Transaction{
         value: value,
         type: type,
         description: description,
         inserted_at: inserted_at
       }) do
    realizada_em =
      inserted_at
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_iso8601()

    %{
      "valor" => value,
      "tipo" => type,
      "descricao" => description,
      "realizada_em" => realizada_em
    }
  end
end
