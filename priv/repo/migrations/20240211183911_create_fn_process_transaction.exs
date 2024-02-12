defmodule RinhaBackend.Repo.Migrations.CreateFnProcessTransaction do
  use Ecto.Migration

  def change do
    execute(~s{
      CREATE OR REPLACE FUNCTION fn_process_transaction(client_id int, value bigint, transaction_type VARCHAR(1), description VARCHAR(10))
      RETURNS BIGINT AS $$
      DECLARE
          transaction_value BIGINT;
          result BIGINT;
      BEGIN
        transaction_value := CASE WHEN transaction_type = 'c' THEN value ELSE value * -1 END;

        INSERT INTO public.transactions (client_id, value, "type", description, inserted_at)
        VALUES (client_id, transaction_value, transaction_type, description, now());

        WITH updated_balance AS (
          UPDATE public.clients
             SET balance = balance + transaction_value
           WHERE id = client_id
             AND (balance + transaction_value) >= (credit_limit * -1)
          RETURNING balance
        )
        SELECT balance INTO result FROM updated_balance;

        IF result IS NULL THEN
          RAISE EXCEPTION 'not_enough_funds';
        ELSE
          RETURN result;
        END IF;
      END;
      $$ LANGUAGE plpgsql;
    }, ~s{
      DROP FUNCTION fn_process_transaction (int, bigint, VARCHAR(1), VARCHAR(10));
    })
  end
end
