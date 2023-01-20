defmodule HildrRoller.Application do
  @moduledoc "Application to return results from requested dice rolls"

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HildrRoller.Endpoint,
        options: [port: Application.fetch_env!(:hildr_roller, :port)]
      )
    ]

    opts = [strategy: :one_for_one, name: HildrRoller.Supervisor]

    Logger.info("Starting application on port #{Application.fetch_env!(:hildr_roller, :port)}")

    Supervisor.start_link(children, opts)
  end
end
