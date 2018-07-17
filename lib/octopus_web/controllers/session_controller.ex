defmodule OctopusWeb.SessionController do
  use OctopusWeb, :controller

  action_fallback OctopusWeb.FallbackController
end
