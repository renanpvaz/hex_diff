defmodule HexDiff.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:hex_diff, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HexDiff.PubSub}
      # Start a worker by calling: HexDiff.Worker.start_link(arg)
      # {HexDiff.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HexDiff.Supervisor)
  end
end
