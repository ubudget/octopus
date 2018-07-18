defmodule OctopusWeb.UserController do
  use OctopusWeb, :controller

  alias Octopus.Accounts
  alias Octopus.Accounts.{Auth, AuthRequest, User}
  alias OctopusWeb.{Mailer, Router.Helpers, UserEmail}
  alias Phoenix.Controller

  action_fallback OctopusWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    # TODO: this needs refactored, but assigning the value of if/else silences
    # pattern matching based error that comes from
    # with {:ok, _} <- Accounts.create_user(...) do
    if user = Accounts.get_user_by_email(user_params["email"]) do
      conn |> auth(user, false) |> render("ok.json")
    else
      with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
        conn |> auth(user, true) |> render("ok.json")
      end
    end
  end

  defp auth(conn, user, new_registration) do
    with {:ok, %AuthRequest{} = req} <- Auth.create_auth_request(conn, user),
         {:ok, _email} <- handle_email(conn, user, req, new_registration) do
      conn
    end
  end

  defp handle_email(conn, user, req, new_registration) do
    link = build_signin_url(conn, req)
    email = case {user, new_registration} do
      {_, true} ->
        UserEmail.registration(user, link)
      {%{activated: false}, false} ->
        UserEmail.reactivate(user, link)
      _ ->
        UserEmail.signin(user, link)
    end
    # TODO: optimize this by making it an async call
    Mailer.deliver(email)
  end

  defp build_signin_url(conn, req) do
    uri = Controller.endpoint_module(conn).struct_url()
    path = Helpers.session_path(conn, :create, [secure_hash: req.secure_hash])
    Helpers.url(uri) <> path
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      conn
      |> maybe_auth(user)
      |> render("show.json", user: user)
    end
  end

  defp maybe_auth(conn, %{activated: true}), do: conn
  defp maybe_auth(conn, user), do: auth(conn, user, false)

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
