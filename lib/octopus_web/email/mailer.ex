defmodule OctopusWeb.Mailer do
  @moduledoc """
  Swoosh Mailer library wrapper for octopus.
  """
  use Swoosh.Mailer, otp_app: :octopus
end
