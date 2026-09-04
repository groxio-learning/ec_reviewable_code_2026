defmodule Wordlex.Repo do
  use Ecto.Repo,
    otp_app: :wordlex,
    adapter: Ecto.Adapters.Postgres
end
