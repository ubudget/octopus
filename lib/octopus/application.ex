defmodule Octopus.Application do
  @moduledoc """
  Entry point for the Octopus monolith.
  """
  use Application
  alias OctopusWeb.Endpoint

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Octopus.Repo, []),
      # Start the endpoint when the application starts
      supervisor(OctopusWeb.Endpoint, []),
      # Start your own worker by calling:
      # worker(Octopus.Worker, [arg1, arg2, arg3]),
      worker(Octopus.Secret, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Octopus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
