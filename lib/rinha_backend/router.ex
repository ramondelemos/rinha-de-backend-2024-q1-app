defmodule RinhaBackend.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/clientes/:id/extrato" do
    id = conn.params["id"]
    send_resp(conn, 200, "extrato from #{id}")
  end

  post "/clientes/:id/transacoes" do
    send_resp(conn, 200, "transacoes")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
