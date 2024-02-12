defmodule RinhaBackend.Controllers.ClientsController do
  @moduledoc false

  alias RinhaBackend.Commands.{
    GenerateStatement
  }

  alias RinhaBackend.Models.{
    Client,
    Transaction
  }

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
