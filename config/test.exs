import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, RinhaBackend.Repo,
  database: "rinhabackend_test",
  username: "rinhabackend-user",
  password: "rinhabackend-pass",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :rinha_backend, RinhaBackend.ReadRepo,
  database: "rinhabackend_test",
  username: "rinhabackend-user",
  password: "rinhabackend-pass",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
