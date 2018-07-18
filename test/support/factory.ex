defmodule Octopus.Factory do
  @moduledoc """
  Defines factories for test fixtures.
  """
  use ExMachina.Ecto, repo: Octopus.Repo
  alias Octopus.Accounts.User

  def user_factory do
    %User{
      name: "John Q. Test",
      email: sequence(:email, &"jqt.#{&1}@email.com"),
    }
  end
end
