defmodule OctopusWeb.Plugs.Authenticate do
  @moduledoc """
  Plug to ensure that only signed in users can access endpoints.
  """
  import Plug.Conn
  alias OctopusWeb.ErrorView
  alias Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if is_nil(conn.assigns[:user_id]) do
      conn
      |> put_status(401)
      |> Controller.put_view(ErrorView)
      |> Controller.render(:no_permission)
    else
      conn
    end
  end
end
