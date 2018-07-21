defmodule OctopusWeb.SessionController do
  use OctopusWeb, :controller
  alias Octopus.Accounts
  alias Octopus.Accounts.Auth

  action_fallback OctopusWeb.FallbackController

  def create(conn, %{"request" => secure_hash}) do
    with {:ok, req} <- Auth.get_request(secure_hash),
         {:ok, _} <- Auth.verify(req),
         {:ok, session} <- Auth.create_session(conn, req.user) do
      Task.start(fn -> Accounts.activate_user(req.user) end)
      Task.start(fn -> Auth.delete(req) end)
      render(conn, "show.json", session: session)
    end
  end

  def delete(conn, %{"id" => secure_hash}) do
    with {:ok, _} <- secure_hash
                     |> Auth.get_session!()
                     |> Auth.delete() do
      send_resp(conn, :no_content, "")
    end
  end
end
