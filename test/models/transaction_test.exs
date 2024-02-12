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

  describe "from_map/1" do
    test "should return a valid changeset when all fields are correct" do
      assert {:ok,
              %RinhaBackend.Models.Transaction{
                client_id: 1,
                type: "c",
                value: 1,
                description: "bonus",
                inserted_at: nil
              }} = Transaction.from_map(@valid_params)
    end

    test "should return a valid changeset when client_id field are not an number" do
      assert @valid_params
             |> Map.replace("client_id", "a")
             |> Transaction.from_map() == {:error, "invalid client id"}
    end

    test "should return a valid changeset when type field are in upper case" do
      transaction =
        @valid_params
        |> Map.replace("type", "C")

      assert {:ok,
              %RinhaBackend.Models.Transaction{
                client_id: 1,
                type: "c",
                value: 1,
                description: "bonus",
                inserted_at: nil
              }} = Transaction.from_map(transaction)
    end

    test "should return a invalid changeset when value is less then 1" do
      assert @valid_params
             |> Map.replace("value", -1)
             |> Transaction.from_map() == {:error, "value must be greater than or equal to 1"}
    end

    test "should return a invalid changeset when description is blank" do
      assert @valid_params
             |> Map.replace("description", nil)
             |> Transaction.from_map() == {:error, "description can't be blank"}
    end

    test "should return a invalid changeset when description is an empty string" do
      assert @valid_params
             |> Map.replace("description", "")
             |> Transaction.from_map() == {:error, "description can't be blank"}
    end

    test "should return a invalid changeset when description length is greater than 10" do
      assert @valid_params
             |> Map.replace("description", "description")
             |> Transaction.from_map() == {:error, "description should be at most 10 characters"}
    end
  end
end
