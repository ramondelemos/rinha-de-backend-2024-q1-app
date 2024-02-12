defmodule RinhaBackend.Models.Transaction do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @transaction_types ["c", "d"]

  @optional_fields [:inserted_at]

  @primary_key false
  schema "transactions" do
    field(:client_id, :integer)
    field(:type, :string)
    field(:value, :integer)
    field(:description, :string)

    timestamps(updated_at: false)
  end

  @spec changeset(Ecto.Schema.t() | Ecto.Changeset.t() | {data :: map(), types :: map()}, map()) ::
          Ecto.Changeset.t()
  def changeset(schema \\ %__MODULE__{}, params) do
    fields = __schema__(:fields)

    schema
    |> cast(params, fields)
    |> validate_required(fields -- @optional_fields)
    |> validate_number(:value, greater_than_or_equal_to: 1)
    |> validate_length(:description, min: 1, max: 10)
    |> sanatize_type()
    |> validate_inclusion(:type, @transaction_types)
  end

  def from_map(params) do
    params
    |> changeset()
    |> case do
      %Ecto.Changeset{valid?: true} = changes ->
        {:ok, Ecto.Changeset.apply_changes(changes)}

      %Ecto.Changeset{
        errors: [client_id: {"is invalid", [type: :integer, validation: :cast]}]
      } ->
        {:error, "invalid client id"}

      %Ecto.Changeset{
        errors: [
          value:
            {"must be greater than or equal to %{number}",
             [validation: :number, kind: :greater_than_or_equal_to, number: number]}
        ]
      } ->
        {:error, "value must be greater than or equal to #{number}"}

      %Ecto.Changeset{
        errors: [description: {"can't be blank", [validation: :required]}]
      } ->
        {:error, "description can't be blank"}

      %Ecto.Changeset{
        errors: [
          description:
            {"should be at most %{count} character(s)",
             [count: 10, validation: :length, kind: :max, type: :string]}
        ]
      } ->
        {:error, "description should be at most 10 characters"}
    end
  end

  defp sanatize_type(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        value =
          changeset
          |> get_field(:type)
          |> String.downcase()

        put_change(changeset, :type, value)

      _ ->
        changeset
    end
  end
end
