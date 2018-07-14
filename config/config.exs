# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :octopus,
  ecto_repos: [Octopus.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :octopus, OctopusWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HpKMEd980yAYQd+lw6KkDR6SFdu/3f+gvfk+yg9rqepV/lxf9hTUyNywTrbT/+Ys",
  render_errors: [view: OctopusWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Octopus.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"