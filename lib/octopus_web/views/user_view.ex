defmodule OctopusWeb.UserView do
  use OctopusWeb, :view
  alias OctopusWeb.UserView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email}
  end

  def render("ok.json", _assigns) do
    %{ok: true}
  end
end
