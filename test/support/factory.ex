defmodule Octopus.Factory do
  @moduledoc """
  Defines factories for test fixtures.
  """
  use ExMachina.Ecto, repo: Octopus.Repo
  alias Octopus.Accounts.{Request, Session, User}
  alias OctopusWeb.Endpoint
  alias Phoenix.Token
  require Logger

  def user_factory do
    %User{
      name: "John Q. Test",
      email: sequence(:email, &"jqt.#{&1}@email.com")
    }
  end

  defp request_salt, do: Application.fetch_env!(:octopus, :request_salt)
  defp session_salt, do: Application.fetch_env!(:octopus, :session_salt)

  def request_factory do
    %Request{
      user: build(:user),
      ip: "127.0.0.1",
      secure_hash: sequence("secret"),
      token: ""
    }
  end

  def session_factory do
    %Session{
      user: build(:user),
      ip: "127.0.0.1",
      secure_hash: sequence("secret"),
      token: ""
    }
  end

  def request_with_token(user) do
    %{build(:request, user: user) | token: Token.sign(Endpoint, request_salt(), user.id)}
    |> insert
  end

  def session_with_token(user) do
    %{build(:session, user: user) | token: Token.sign(Endpoint, session_salt(), user.id)}
    |> insert
  end
end
