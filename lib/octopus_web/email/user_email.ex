defmodule OctopusWeb.UserEmail do
  @moduledoc """
  Defines the mailer info for user registration and sign in emails.
  """
  import Swoosh.Email

  def attrs(email, user) do
    email
    |> to({user.name, user.email})
    |> from({"Team ubudget", "team@ubudget.site"})
  end

  def registration(user, link) do
    new()
    |> attrs(user)
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
    |> attrs(user)
    |> subject("Sign in to ubudget")
    # TODO: better HTML email template
    |> html_body("""
    <p>Hello, #{user.name}, and welcome back to ubudget.</p>

    <p>Please click <a href="#{link}">here</a> or go to the url below to sign up.</p>

    <a href="#{link}">#{link}</a>
    """)
  end

  def reactivate(user, link) do
    new()
    |> attrs(user)
    |> subject("Reactivate with your new email")
    # TODO: better HTML email template
    |> html_body("""
    <p>Hello, #{user.name}, we noticed you updated your email.</p>

    <p>Please click <a href="#{link}"here</a> to log in and reactivate or go to the url below.</p>

    <a href="#{link}">#{link}</a>
    """)
  end
end
