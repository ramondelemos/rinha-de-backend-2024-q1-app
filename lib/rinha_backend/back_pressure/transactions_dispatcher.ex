defmodule RinhaBackend.BackPressure.TransactionsDispatcher do
  @moduledoc """
  Module responsible to enqueue client transactions.
  """

  alias RinhaBackend.BackPressure.{Supervisor, TransactionsProducer}
  alias RinhaBackend.Models.Transaction

  def dispatch(%Transaction{client_id: client_id} = transaction) do
    timeout = get_timeout()

    with {:ok, pid} <- Supervisor.start_producer(client_id),
         :ok <- TransactionsProducer.enqueue(pid, self(), transaction) do
      receive do
        {:done, response} ->
          response

        {:rescue,
         %{
           reason: exception,
           stack: stack
         }} ->
          reraise exception, stack
      after
        timeout -> raise "timeout"
      end
    else
      error -> {:error, error}
    end
  end

  defp get_timeout do
    :rinha_backend
    |> Application.fetch_env!(:back_pressure)
    |> Keyword.fetch!(:timeout)
  end
end
