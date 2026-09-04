defmodule WordleGame.Repo do
  use Ecto.Repo,
    otp_app: :wordle_game,
    adapter: Ecto.Adapters.Postgres
end
