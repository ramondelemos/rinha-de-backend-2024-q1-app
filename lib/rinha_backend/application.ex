defmodule RinhaBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @app :rinha_backend

  @impl true
  def start(_type, _args) do
    :ets.new(:client_producers, [:public, :named_table])

    if execute_migrations?() do
      migrate()
    end

    children = [
      RinhaBackend.Repo,
      RinhaBackend.ReadRepo,
      {Registry, keys: :unique, name: RinhaBackend.BackPressure.TransactionsProducerRegistry},
      {RinhaBackend.BackPressure.Supervisor, []},
      {Plug.Cowboy, scheme: :http, plug: RinhaBackend.Router, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp migrate do
    Application.load(@app)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      repo.__adapter__().storage_up(repo.config())
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp execute_migrations? do
    Application.get_env(@app, :execute_migrations)
  end
end
