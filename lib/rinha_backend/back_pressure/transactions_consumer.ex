defmodule RinhaBackend.BackPressure.TransactionsConsumer do
  @moduledoc """
  A GenStage that processes demand of client transactions.
  """

  use ConsumerSupervisor

  alias RinhaBackend.BackPressure.TransactionsProducer
  alias RinhaBackend.BackPressure.TransactionExecutor

  require Logger

  #############################
  # Client (Public) Interface #
  #############################

  def start_link(client_id) do
    ConsumerSupervisor.start_link(__MODULE__, client_id, name: via_tuple(client_id))
  end

  ####################
  # Server Callbacks #
  ####################

  def init(client_id) do
    Logger.debug("Back pressure consumer to client_account [#{inspect(client_id)}] started",
      client_id: inspect(client_id)
    )

    children = [
      %{
        id: TransactionExecutor,
        start: {TransactionExecutor, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{TransactionsProducer.via_tuple(client_id), max_demand: get_max_demand()}]
    ]

    ConsumerSupervisor.init(children, opts)
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

  defp get_max_demand do
    :rinha_backend
    |> Application.fetch_env!(:back_pressure)
    |> Keyword.fetch!(:max_demand)
  end
end
