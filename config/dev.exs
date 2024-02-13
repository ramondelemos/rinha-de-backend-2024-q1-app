import Config

config :rinha_backend, RinhaBackend.Repo,
  database: "rinhabackend",
  username: "rinhabackend-user",
  password: "rinhabackend-pass",
  hostname: "localhost"

config :rinha_backend, RinhaBackend.ReadRepo,
  database: "rinhabackend",
  username: "rinhabackend-user",
  password: "rinhabackend-pass",
  hostname: "localhost"
