defmodule Octopus.Secure do
  @moduledoc """
  Defines security related functionality.
  """
  alias Octopus.Secret
  alias Plug.Conn

  @doc """
  Secure hash method taken from Veil:
  https://github.com/zanderxyz/veil/blob/master/lib/veil/secure.ex#L18

  To form a secure id, we concatenate together:
  * 24-40 random bytes
  * user ip address
  * user agent string
  * system time in ms
  * server secret (re-generated every time the server starts)
  Then SHA512 the result, and encode in Base32 (so we can transmit it as part of a URL).
  """
  def generate_hash(conn) do
    prefix = :crypto.strong_rand_bytes(23 + :rand.uniform(17))
    ip = get_user_ip(conn)
    user_agent = get_user_agent(conn)
    system_time = :os.system_time() |> to_string()
    secret = Secret.get()
    input = prefix <> ip <> (user_agent || "") <> system_time <> secret
    hashed = :crypto.hash(:sha512, input)
    Base.encode32(hashed)
  end

  @doc """
  Gets the IP address of the client
  Taken from Veil
  """
  def get_user_ip(conn) do
    forwarded_ip =
      conn
      |> Conn.get_req_header("x-forwarded-for")
      |> List.first()

    if not is_nil(forwarded_ip) do
      forwarded_ip
    else
      conn.remote_ip
      |> Tuple.to_list()
      |> join_ip()
    end
  end

  defp join_ip(list) do
    case length(list) do
      8 -> Enum.join(list, ":")
      _ -> Enum.join(list, ".")
    end
  end

  defp get_user_agent(conn) do
    conn
    |> Conn.get_req_header("user-agent")
    |> List.first()
  end
end
