import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, execute_migrations: false

import_config "#{config_env()}.exs"
