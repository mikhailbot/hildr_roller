defmodule HildrRoller.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts HildrRoller.Endpoint.init([])

  test "it returns pong" do
    conn = conn(:get, "/ping")

    conn = HildrRoller.Endpoint.call(conn, @opts)

    pong_as_json = %{result: "pong"} |> Poison.encode!()

    assert conn.status == 200
    assert conn.resp_body == pong_as_json
  end

  test "it returns 400 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = HildrRoller.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 400
  end

  test "it returns a dice result" do
    conn = conn(:post, "/roll", %{data: 'd1'})

    conn = HildrRoller.Endpoint.call(conn, @opts)

    result_as_json = %{result: 1} |> Poison.encode!()

    assert conn.status == 200
    assert conn.resp_body == result_as_json
  end

  test "it returns an error on invalid request" do
    conn = conn(:post, "/roll", %{data: 'd1d2d3'})

    conn = HildrRoller.Endpoint.call(conn, @opts)

    assert conn.status == 400
  end
end
