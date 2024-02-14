import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, execute_migrations: false

config :rinha_backend, RinhaBackend.Commands.GenerateStatement, repo: RinhaBackend.Repo

config :rinha_backend, :back_pressure, enabled: true, timeout: 20000, max_demand: 10

import_config "#{config_env()}.exs"
