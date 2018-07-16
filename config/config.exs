# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :octopus,
  ecto_repos: [Octopus.Repo],
  generators: [binary_id: true],
  auth_request_salt: "2/5mm5eunE3Io20vqREgr3UkEyb8JLz1oIGuko3ZXtuYy9rkzMGjLQV+mUfHEd8c",
  session_salt: "u0l1+3qnmise4kEFLxnwlc35BGtzgAPqpdQFaJIyr4J0IMSh+JedChUbtXGWqv7C"

# Configures the endpoint
config :octopus, OctopusWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DbYXzAJFQHMCUWM4slg3GN0PuEo/PDD7vTeheV68zq5WneOrkyEWWTactA9cbE0x",
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
