defmodule OctopusWeb.Plugs.UserId do
  @moduledoc """
  Plug to ensure the presence of the logged in user's id in the session.
  """
  import Plug.Conn
  alias Octopus.Accounts.Auth

  def init(opts), do: opts

  def call(%Plug.Conn{params: %{"session" => secure_hash}} = conn, _opts) do
    with {:ok, session} <- Auth.get_session(secure_hash),
         {:ok, user_id} <- Auth.verify(session),
         true <- user_id == session.user.id do
      Task.start(fn -> Auth.extend_session(session) end)

      conn
      |> assign(:user_id, user_id)
      |> assign(:session, secure_hash)
    else
      _ -> conn
    end
  end

  def call(conn, _opts), do: conn
end
