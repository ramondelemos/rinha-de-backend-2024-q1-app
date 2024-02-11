defmodule RinhaBackend.Models.TransactionTest do
  use ExUnit.Case

  doctest RinhaBackend

  alias RinhaBackend.Models.Transaction

  @valid_params %{
    "client_id" => 1,
    "type" => "c",
    "value" => 1,
    "description" => "bonus"
  }

  describe "changeset/2" do
    test "should return a valid changeset when all fields are correct" do
      changeset = Transaction.changeset(@valid_params)

      assert changeset.valid? == true
    end

    test "should return a valid changeset when client_id field are not an number" do
      changeset =
        @valid_params
        |> Map.replace("client_id", "a")
        |> Transaction.changeset()

      assert %Ecto.Changeset{
               errors: [client_id: {"is invalid", [type: :integer, validation: :cast]}],
               valid?: false
             } = changeset
    end

    test "should return a valid changeset when type field are in upper case" do
      changeset =
        @valid_params
        |> Map.replace("type", "C")
        |> Transaction.changeset()

      assert changeset.valid? == true
      assert changeset.changes.type == "c"
    end

    test "should return a invalid changeset when value is less then 1" do
      changeset =
        @valid_params
        |> Map.replace("value", -1)
        |> Transaction.changeset()

      assert %Ecto.Changeset{
               errors: [
                 value:
                   {"must be greater than or equal to %{number}",
                    [validation: :number, kind: :greater_than_or_equal_to, number: 1]}
               ],
               valid?: false
             } = changeset
    end

    test "should return a invalid changeset when description is blank" do
      changeset =
        @valid_params
        |> Map.replace("description", nil)
        |> Transaction.changeset()

      assert %Ecto.Changeset{
               errors: [description: {"can't be blank", [validation: :required]}],
               valid?: false
             } = changeset
    end

    test "should return a invalid changeset when description is an empty string" do
      changeset =
        @valid_params
        |> Map.replace("description", "")
        |> Transaction.changeset()

      assert %Ecto.Changeset{
               errors: [description: {"can't be blank", [validation: :required]}],
               valid?: false
             } = changeset
    end

    test "should return a invalid changeset when description length is greater than 10" do
      changeset =
        @valid_params
        |> Map.replace("description", "description")
        |> Transaction.changeset()

      assert %Ecto.Changeset{
               errors: [
                 description:
                   {"should be at most %{count} character(s)",
                    [count: 10, validation: :length, kind: :max, type: :string]}
               ],
               valid?: false
             } = changeset
    end
  end
end
