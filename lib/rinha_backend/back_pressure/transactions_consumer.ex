defmodule RinhaBackend.BackPressure.TransactionsConsumer do
  @moduledoc """
  A GenStage that processes demand of client transactions.
  """

  use GenStage

  alias RinhaBackend.BackPressure.TransactionsProducer
  alias RinhaBackend.Commands.ProcessTransaction
  alias RinhaBackend.Models.Transaction

  require Logger

  #############################
  # Client (Public) Interface #
  #############################

  def start_link(client_id) do
    GenStage.start_link(__MODULE__, client_id, name: via_tuple(client_id))
  end

  ####################
  # Server Callbacks #
  ####################

  def init(client_id) do
    {
      :consumer,
      client_id,
      subscribe_to: [
        {TransactionsProducer.via_tuple(client_id), max_demand: get_max_demand()}
      ]
    }
  end

  def handle_events(events, from, state) do
    process_events(events, from, state)
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  def terminate({:shutdown, :timeout}, _state) do
    :ok
  end

  def terminate(_reason, _state) do
    :ok
  end

  @doc """
  Returns a tuple used to register and lookup an consumer process by name.
  """
  def via_tuple(client_id) do
    {:via, Registry,
     {RinhaBackend.BackPressure.TransactionsProducerRegistry, {:consumer, client_id}}}
  end

  @doc """
  Returns the `pid` of the consumer process registered under the
  given `client_id`, or `nil` if no process is registered.
  """
  def get_pid(client_id) do
    client_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  def process_events(events, _from, state) when length(events) > 0 do
    events
    |> Enum.map(fn {process_owner, transaction, published_at} ->
      Task.async(fn ->
        execute(process_owner, transaction, published_at)
      end)
    end)
    |> Task.await_many(7_000)

    # As a consumer we never emit events
    {:noreply, [], state}
  end

  def process_events(_events, _from, state), do: {:noreply, [], state}

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

  defp get_max_demand do
    :rinha_backend
    |> Application.get_env(:back_pressure)
    |> Keyword.get(:max_demand, 150)
  end

  defp get_timeout do
    :rinha_backend
    |> Application.get_env(:back_pressure)
    |> Keyword.get(:timeout, 1000)
  end
end
