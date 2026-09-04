defmodule EcWordle.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EcWordleWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:ec_wordle, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EcWordle.PubSub},
      # Start a worker by calling: EcWordle.Worker.start_link(arg)
      # {EcWordle.Worker, arg},
      # Start to serve requests, typically the last entry
      EcWordleWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EcWordle.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EcWordleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
