defmodule RinhaBackend.Models.Client do
  @moduledoc false

  use Ecto.Schema

  @type t :: %__MODULE__{}

  @primary_key false
  schema "clients" do
    field(:id, :integer, primary_key: true)
    field(:credit_limit, :integer)
    field(:balance, :integer, default: 0)
  end
end
