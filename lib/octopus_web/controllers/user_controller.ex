defmodule OctopusWeb.UserController do
  use OctopusWeb, :controller

  alias Octopus.Accounts
  alias Octopus.Accounts.{Auth, AuthRequest, User}
  alias OctopusWeb.{Mailer, Router.Helpers, UserEmail}
  alias Phoenix.Controller

  action_fallback OctopusWeb.FallbackController

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    if user = Accounts.get_user_by_email(email) do
      auth(conn, user, false)
    else
      with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
        auth(conn, user, true)
      end
    end
  end

  defp auth(conn, user, new_registration) do
    with {:ok, %AuthRequest{} = req} <- Auth.create_auth_request(conn, user),
         {:ok, _email} <- handle_email(conn, user, req, new_registration) do
      render(conn, "ok.json")
    end
  end

  defp handle_email(conn, user, req, new_registration) do
    # TODO: good candidate for refactoring, probably
    email_fn = if new_registration do
      &UserEmail.registration/2
    else
      &UserEmail.signin/2
    end

    link = build_signin_url(conn, req)

    user
    |> email_fn.(link)
    |> Mailer.deliver()
  end

  defp build_signin_url(conn, req) do
    uri = Controller.endpoint_module(conn).struct_url()
    path = Helpers.session_path(conn, :create, [secure_hash: req.secure_hash])
    Helpers.url(uri) <> path
  end

  def update(conn, %{"id" => id, "user" => %{"email" => _} = user_params}) do
    user = Accounts.get_user!(id)
    user_params = Map.put(user_params, "verified", false)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
