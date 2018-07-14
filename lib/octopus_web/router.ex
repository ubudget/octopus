defmodule OctopusWeb.Router do
  use OctopusWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OctopusWeb do
    pipe_through :api
  end
end
