defmodule RinhaBackend.BackPressure.TransactionsProducer do
  @moduledoc """
  A GenServer that produce demand of client transactions to be executed.
  """

  use GenStage

  require Logger

  @timeout :timer.minutes(1)
  @work_interval :timer.seconds(10)

  #############################
  # Client (Public) Interface #
  #############################

  @doc """
  Spawns a new processor registered under the given `client_id`.
  """
  def start_link(client_id) do
    state = %{
      client_id: client_id,
      updated_at: NaiveDateTime.utc_now()
    }

    GenStage.start_link(
      __MODULE__,
      state,
      name: via_tuple(client_id)
    )
  end

  def state(client_id) do
    GenServer.call(via_tuple(client_id), :state)
  end

  def enqueue(client_id, process_owner, transaction) when is_integer(client_id) do
    GenServer.cast(via_tuple(client_id), {:enqueue, process_owner, transaction})
  end

  def enqueue(pid, process_owner, transaction) do
    GenServer.cast(pid, {:enqueue, process_owner, transaction})
  end

  @doc """
  Returns a tuple used to register and lookup an producer process by name.
  """
  def via_tuple(client_id) do
    {:via, Registry,
     {RinhaBackend.BackPressure.TransactionsProducerRegistry, {:producer, client_id}}}
  end

  @doc """
  Returns the `pid` of the producer process registered under the
  given `client_id`, or `nil` if no process is registered.
  """
  def get_pid(client_id) do
    client_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  ####################
  # Server Callbacks #
  ####################

  def init(state) do
    Logger.debug("Starting back pressure to client_account [#{inspect(state.client_id)}]",
      client_id: inspect(state.client_id)
    )
    schedule_work()
    {:producer, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, [], state}
  end

  # Adding demand to consumers
  def handle_cast({:enqueue, process_owner, transaction}, %{client_id: client_id}) do
    now = NaiveDateTime.utc_now()

    state = %{
      client_id: client_id,
      updated_at: now
    }

    {:noreply, [{process_owner, transaction, now}], state}
  end

  # Ignore any demand from consumers
  def handle_demand(_, state), do: {:noreply, [], state}

  def handle_info(:work, state) do
    if idle?(state) do
      send(self(), :timeout)
    else
      schedule_work()
    end

    {:noreply, [], state}
  end

  def handle_info(:timeout, %{client_id: client_id} = state) do
    Logger.debug("Back pressure to client_account [#{inspect(client_id)}] timed out",
      client_id: inspect(client_id)
    )

    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, %{client_id: client_id}) do
    Logger.debug("Terminating back pressure to client_account [#{inspect(client_id)}] by time out",
      client_id: inspect(client_id)
    )

    :ok
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp schedule_work do
    Process.send_after(self(), :work, @work_interval)
  end

  defp idle?(%{updated_at: updated_at}) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), updated_at, :millisecond) > @timeout
  end
end
