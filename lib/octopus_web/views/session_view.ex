defmodule OctopusWeb.SessionView do
  use OctopusWeb, :view
  alias OctopusWeb.SessionView

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{secure_hash: session.secure_hash}
  end
end
