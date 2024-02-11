import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, RinhaBackend.Repo,
  database: "rinhabackend",
  username: "rinhabackend-user",
  password: "rinhabackend-pass",
  hostname: "localhost"
