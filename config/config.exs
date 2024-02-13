import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, execute_migrations: false

config :rinha_backend, RinhaBackend.Commands.GenerateStatement, repo: RinhaBackend.Repo

import_config "#{config_env()}.exs"
