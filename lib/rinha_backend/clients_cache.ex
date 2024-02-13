defmodule RinhaBackend.ClientsCache do
  @moduledoc false

  use GenServer

  alias RinhaBackend.Models.Client
  alias RinhaBackend.Repo

  def init(_) do
    :ets.new(:clients_cache, [
      :set,
      :public,
      :named_table,
      decentralized_counters: true,
      write_concurrency: true
    ])

    {:ok, nil}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_client(client_id) do
    client_id
    |> get_in_ets()
    |> case do
      nil ->
        get_client_in_db(client_id)

      %Client{} = client ->
        client
    end
  end

  defp put_in_ets(client_id, client), do: :ets.insert(:clients_cache, {client_id, client})

  defp get_in_ets(client_id) do
    :ets.lookup(:clients_cache, client_id)
    |> List.first()
    |> case do
      nil -> nil
      t -> elem(t, 1)
    end
  end

  defp get_client_in_db(client_id) do
    case Repo.get(Client, client_id) do
      nil ->
        nil

      %Client{} = client ->
        put_in_ets(client_id, client)
        client
    end
  end
end
