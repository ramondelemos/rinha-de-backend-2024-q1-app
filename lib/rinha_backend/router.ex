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
    send_resp(conn, 200, "transacoes")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
