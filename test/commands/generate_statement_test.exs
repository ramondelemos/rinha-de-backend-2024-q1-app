defmodule RinhaBackend.Commands.GenerateStatementTest do
  use RinhaBackend.RepoCase

  doctest RinhaBackend

  alias RinhaBackend.Commands.{
    GenerateStatement,
    ProcessTransaction
  }

  alias RinhaBackend.Models.{
    Client,
    Transaction
  }

  describe "execute/1" do
    test "should return client with 0 balance and no transactions when transactions not processed" do
      assert {:ok, %Client{balance: 0} = client} = GenerateStatement.execute(1)
      assert Enum.count(client.transactions) == 0
    end

    test "should return client with balance 1 and one transactions when one transaction are executed" do
      transaction = %Transaction{
        client_id: 1,
        type: "c",
        value: 1,
        description: "description"
      }

      assert {:ok, 1} == ProcessTransaction.execute(transaction)

      assert {:ok, %Client{balance: 1} = client} = GenerateStatement.execute(1)
      assert Enum.count(client.transactions) == 1
    end

    test "should return client with balance 11 and 10 transactions when 11 transactions are executed" do
      transaction = %Transaction{
        client_id: 1,
        type: "c",
        value: 1,
        description: "description"
      }

      Enum.each(1..11, fn balance ->
        assert {:ok, ^balance} = ProcessTransaction.execute(transaction)
      end)

      assert {:ok, %Client{balance: 11} = client} = GenerateStatement.execute(1)
      assert Enum.count(client.transactions) == 10
    end

    test "should return that client not_found with invalid client id" do
      assert {:error, :client_not_found} = GenerateStatement.execute(6)
    end
  end
end
