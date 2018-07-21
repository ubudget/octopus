defmodule OctopusWeb.Plugs.User do
  @moduledoc """
  Plug to ensure the presence of the logged in user's id in the session.
  """
  import Plug.Conn
  alias Octopus.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    if user_id = conn.assigns[:user_id] do
      assign(conn, :user, Accounts.get_user!(user_id))
    else
      conn
    end
  end
end
