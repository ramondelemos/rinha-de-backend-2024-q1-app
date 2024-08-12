defmodule RinhaBackend.BackPressure.TransactionExecutor do
  alias RinhaBackend.Commands.ProcessTransaction
  alias RinhaBackend.Models.Transaction

  require Logger

  def start_link({process_owner, transaction, published_at}) do
    Task.start_link(fn ->
      execute(process_owner, transaction, published_at)
    end)
  end

  defp execute(process_owner, transaction, published_at) do
    waiting_time = NaiveDateTime.diff(NaiveDateTime.utc_now(), published_at, :millisecond)

    if waiting_time > get_timeout() do
      Logger.debug("transaction droped")
    else
      response = do_execute(transaction)
      send(process_owner, {:done, response})
      Logger.debug("transaction executed")
    end
  rescue
    exception ->
      fail = %{
        reason: Exception.message(exception),
        stack: __STACKTRACE__
      }

      send(process_owner, {:rescue, fail})
  end

  defp do_execute(%Transaction{} = transaction), do: ProcessTransaction.execute(transaction)

  defp get_timeout do
    :rinha_backend
    |> Application.fetch_env!(:back_pressure)
    |> Keyword.fetch!(:timeout)
  end
end
