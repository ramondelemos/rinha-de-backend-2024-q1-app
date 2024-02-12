defmodule RinhaBackend.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias RinhaBackend.Repo

      import Ecto
      import Ecto.Query
      import RinhaBackend.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RinhaBackend.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RinhaBackend.Repo, {:shared, self()})
    end

    :ok
  end
end
