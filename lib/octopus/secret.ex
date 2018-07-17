defmodule Octopus.Secret do
  @moduledoc """
  Agent for storing a server secret, taken from Veil:
  https://github.com/zanderxyz/veil/blob/master/lib/veil/secret.ex
  """
  use Agent

  @doc """
  Starts the Agent with 24-40 random bytes as the secret.
  """
  def start_link do
    Agent.start_link(fn -> create_secret() end, name: __MODULE__)
  end

  defp create_secret do
    :crypto.strong_rand_bytes(23 + :rand.uniform(17))
  end

  @doc """
  Gets the secret from the Agent.
  """
  def get do
    Agent.get(__MODULE__, & &1)
  end
end
