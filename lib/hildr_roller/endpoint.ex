defmodule HildrRoller.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  plug(:dispatch)

  get "/ping" do
    conn
    |> Plug.Conn.prepend_resp_headers([{"content-type", "application/json"}])
    |> send_resp(200, Poison.encode!(%{result: "pong"}))
  end

  match _ do
    conn
    |> Plug.Conn.prepend_resp_headers([{"content-type", "application/json"}])
    |> send_resp(400, Poison.encode!(%{result: "error"}))
  end
end
