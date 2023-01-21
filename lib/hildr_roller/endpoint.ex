defmodule HildrRoller.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """
  alias HildrRoller.Dice

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

  post "/roll" do
    {status, body} =
      case conn.body_params do
        %{"data" => data} -> process_data(data)
        _ -> {422, missing_data()}
      end

    send_resp(conn, status, body)
  end

  match _ do
    conn
    |> Plug.Conn.prepend_resp_headers([{"content-type", "application/json"}])
    |> send_resp(400, Poison.encode!(%{result: "error"}))
  end

  defp process_data(data) when is_list(data) do
    with {:ok, %{quantity: _q, result: result, sides: _s}} <- Dice.generate(List.to_string(data)) do
      {200, Poison.encode!(%{result: result})}
    else
      _ -> {400, return_error()}
    end

  end

  defp process_data(_) do
    return_error()
  end

  defp return_error() do
    Poison.encode!(%{result: "failed to process data"})
  end

  defp missing_data do
    Poison.encode!(%{result: "Expected Payload: { 'data': '2d6' }"})
  end
end
