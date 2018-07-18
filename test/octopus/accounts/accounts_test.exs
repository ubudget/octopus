defmodule Octopus.AccountsTest do
  @moduledoc false
  use Octopus.DataCase

  alias Octopus.Accounts

  describe "users" do
    alias Octopus.Accounts.User

    @valid_attrs %{name: "John Q. Test", email: "jqt@email.com"}
    @invalid_attrs %{}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_email returns the user with given email" do
      user = user_fixture()
      assert Accounts.get_user_by_email(user.email) == user
    end

    test "get_user_by_email finds a user given its uppercase email" do
      user = user_fixture()
      assert user.email
      |> String.upcase()
      |> Accounts.get_user_by_email() == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "jqt@email.com"
      assert user.name == "John Q. Test"
      refute user.activated
    end

    test "create_user/1 with uppercase email becomes lowercase" do
      attrs = %{@valid_attrs | email: "JQT@EMAIL.COM"}
      assert {:ok, %User{} = user} = Accounts.create_user(attrs)
      assert user.email == "jqt@email.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "activate_user sets a user to activated" do
      user = user_fixture()
      refute user.activated
      assert {:ok, user} = Accounts.activate_user(user)
      assert user.activated
    end

    test "update_user/2 with valid email updates the user" do
      {:ok, user} = user_fixture() |> Accounts.activate_user()
      attrs = %{email: "JQT@email.net"}
      assert {:ok, user} = Accounts.update_user(user, attrs)
      assert %User{} = user
      assert user.email == "jqt@email.net"
      refute user.activated
    end

    test "update_user/2 with valid name updates the user" do
      user = user_fixture()
      attrs = %{name: "JQT"}
      assert {:ok, user} = Accounts.update_user(user, attrs)
      assert %User{} = user
      assert user.name == "JQT"
    end

    test "update_user/2 with invalid name returns error changeset" do
      user = user_fixture()
      attrs = %{name: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 with invalid email returns error changeset" do
      user = user_fixture()
      attrs = %{email: "invalid"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "delete_unactivated_users deletes unactivated users" do
      user = user_fixture()
      assert Accounts.delete_unactivated_users() == {1, nil}
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "delete_unactivated_users leaves activated users" do
      {:ok, user} = user_fixture() |> Accounts.activate_user()
      assert Accounts.delete_unactivated_users() == {0, nil}
      assert user == Accounts.get_user!(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
