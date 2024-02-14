import Config

# All configs that depend of env values must be configured here

import System, only: [get_env: 1, fetch_env!: 1]
import String, only: [to_integer: 1]

fetch_integer! = fn var -> var |> fetch_env!() |> to_integer() end

get_boolean = fn var ->
  var |> get_env() |> Kernel.to_string() |> String.downcase() |> Kernel.==("true")
end

config :rinha_backend, execute_migrations: get_boolean.("EXECUTE_MIGRATIONS")

config :rinha_backend, RinhaBackend.Repo,
  username: fetch_env!("DATABASE_USER"),
  password: fetch_env!("DATABASE_PASSWORD"),
  database: fetch_env!("DATABASE_NAME"),
  hostname: fetch_env!("DATABASE_HOST"),
  port: fetch_integer!.("DATABASE_PORT"),
  pool_size: fetch_integer!.("DATABASE_POOL_SIZE")

config :rinha_backend, RinhaBackend.ReadRepo,
  username: fetch_env!("DATABASE_USER"),
  password: fetch_env!("DATABASE_PASSWORD"),
  database: fetch_env!("DATABASE_NAME"),
  hostname: fetch_env!("DATABASE_HOST"),
  port: fetch_integer!.("DATABASE_PORT"),
  pool_size: fetch_integer!.("READ_DATABASE_POOL_SIZE")

config :rinha_backend, RinhaBackend.Commands.GenerateStatement, repo: RinhaBackend.ReadRepo

config :rinha_backend, :back_pressure,
  enabled: get_boolean.("BACK_PRESSURE_ENABLED"),
  timeout: fetch_integer!.("BACK_PRESSURE_TIMEOUT"),
  max_demand: fetch_integer!.("BACK_PRESSURE_MAX_CONCURRENCY")
