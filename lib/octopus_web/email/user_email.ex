defmodule OctopusWeb.UserEmail do
  @moduledoc """
  Defines the mailer info for user registration and sign in emails.
  """
  import Swoosh.Email

  def registration(user, link) do
    new()
    |> to({user.name, user.address})
    |> from({"Team ubudget", "team@ubudget.site"})
    |> subject("Welcome to ubudget!")
    # TODO: better HTML email template
    |> html_body("""
    <p>Hello, #{user.name}, and welcome to ubudget!</p>

    <p>Please click <a href="#{link}">here</a> or go to the url below to sign in.</p>

    <a href="#{link}">#{link}</a>
    """)
  end

  def signin(user, link) do
    new()
    |> to({user.name, user.address})
    |> from({"Team ubudget", "team@ubudget.site"})
    |> subject("Sign in to ubudget")
    # TODO: better HTML email template
    |> html_body("""
    <p>Hello, #{user.name}, and welcome back to ubudget.</p>

    <p>Please click <a href="#{link}">here</a> or go to the url below to sign in.</p>

    <a href="#{link}">#{link}</a>
    """)
  end
end
