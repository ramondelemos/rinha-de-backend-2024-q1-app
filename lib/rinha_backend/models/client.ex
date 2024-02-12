defmodule RinhaBackend.Models.Client do
  @moduledoc false

  use Ecto.Schema

  alias RinhaBackend.Models.Transaction

  @type t :: %__MODULE__{}

  @primary_key false
  schema "clients" do
    field(:id, :integer, primary_key: true)
    field(:credit_limit, :integer)
    field(:balance, :integer, default: 0)

    has_many(:transactions, Transaction, references: :id)
  end
end
