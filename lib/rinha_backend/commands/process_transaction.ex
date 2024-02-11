defmodule RinhaBackend.Commands.ProcessTransaction do
  @moduledoc false

  alias RinhaBackend.Repo
  alias RinhaBackend.Models.Transaction

  def execute(%Transaction{
        client_id: client_id,
        type: type,
        value: value,
        description: description
      }) do
    ~s{ select fn_process_transaction($1, $2, $3, $4) as balance }
    |> Repo.query([client_id, value, type, description], [])
    |> case do
      {:ok,
       %Postgrex.Result{
         columns: ["balance"],
         rows: [[balance]]
       }} ->
        {:ok, balance}

      {:error,
       %Postgrex.Error{
         message: nil,
         postgres: %{
           code: :raise_exception,
           message: "not_enough_funds"
         }
       }} ->
        {:error, :not_enough_funds}

      {:error,
       %Postgrex.Error{
         message: nil,
         postgres: reason
       }} ->
        {:error, reason}
    end
  end
end
