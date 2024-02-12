defmodule RinhaBackend.Commands.ProcessTransactionTest do
  use RinhaBackend.RepoCase

  doctest RinhaBackend

  alias Ecto.UUID
  alias RinhaBackend.Commands.ProcessTransaction
  alias RinhaBackend.Repo
  alias RinhaBackend.Models.Client
  alias RinhaBackend.Models.Transaction

  describe "execute/1" do
    test "should process transaction with success when executend with a valid transaction" do
      %Client{balance: balance, credit_limit: limit} = Repo.get(Client, 1)

      description = UUID.generate()

      transaction = %Transaction{
        client_id: 1,
        type: "c",
        value: 1,
        description: description
      }

      assert ProcessTransaction.execute(transaction) == {:ok, {balance + 1, limit}}

      assert %Transaction{
               client_id: 1,
               type: "c",
               value: 1,
               description: ^description
             } = Repo.get_by(Transaction, description: description)
    end

    test "should fail when transaction exceed the client limit" do
      client_id = 2
      %Client{balance: balance, credit_limit: credit_limit} = Repo.get(Client, client_id)

      description = UUID.generate()

      transaction = %Transaction{
        client_id: client_id,
        type: "d",
        value: balance + credit_limit + 1,
        description: description
      }

      assert ProcessTransaction.execute(transaction) == {:error, :not_enough_funds}

      assert Repo.get_by(Transaction, description: description) == nil
    end
  end
end
