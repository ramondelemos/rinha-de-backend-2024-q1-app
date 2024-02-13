defmodule RinhaBackend.BackPressure.Supervisor do
  @moduledoc """
  A supervisor that starts `TransactionsProducer` and `TransactionsConsumer` processes dynamically.
  """

  use DynamicSupervisor

  alias RinhaBackend.BackPressure.{TransactionsConsumer, TransactionsProducer}

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a `TransactionsProducer` and `TransactionsConsumer` process and supervises them.
  """
  def start_producer(client_id) do
    producer = start_process(TransactionsProducer, client_id)
    {:ok, _pid} = start_consumer(client_id)
    producer
  end

  @doc """
  Terminates the `TransactionsProducer` and `TransactionsConsumer` process normally. It won't be restarted.
  """
  def stop_producer(client_id) do
    child_pid = TransactionsProducer.get_pid(client_id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  @doc """
  List all the `TransactionsProducer` and `TransactionsConsumer` process.
  """
  def list_servers do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, server_pid, _, _} ->
      RinhaBackend.BackPressure.TransactionsProducerRegistry
      |> Registry.keys(server_pid)
      |> List.first()
    end)
  end

  defp start_consumer(client_id) do
    start_process(TransactionsConsumer, client_id)
  end

  defp start_process(module, client_id) do
    case module.get_pid(client_id) do
      nil ->
        child_spec = %{
          id: module,
          start: {module, :start_link, [client_id]},
          restart: :transient
        }

        case DynamicSupervisor.start_child(__MODULE__, child_spec) do
          {:ok, pid} ->
            {:ok, pid}

          {:error, {:already_started, pid}} ->
            {:ok, pid}
        end

      pid ->
        {:ok, pid}
    end
  end
end
