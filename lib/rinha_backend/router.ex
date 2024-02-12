defmodule RinhaBackend.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias RinhaBackend.Controllers.ClientsController

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/clientes/:id/extrato" do
    id = conn.params["id"]

    case ClientsController.get_statement(id) do
      {:ok, statement} ->
        send_resp(conn, 200, statement)

      {:error, :not_found} ->
        send_resp(conn, 404, "not found")

      {:error, :invalid_client_id} ->
        send_resp(conn, 400, "invalid client id")
    end
  end

  post "/clientes/:id/transacoes" do
    id = conn.params["id"]
    params = conn.body_params

    case ClientsController.create_transaction(id, params) do
      {:ok, result} ->
        send_resp(conn, 200, result)

      {:error, :not_enough_funds} ->
        send_resp(conn, 422, "not enough funds")

      {:error, :not_found} ->
        send_resp(conn, 404, "not found")

      {:error, reason} ->
        send_resp(conn, 400, inspect(reason))
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
