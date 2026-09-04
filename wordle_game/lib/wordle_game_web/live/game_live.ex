defmodule WordleGameWeb.GameLive do
  use WordleGameWeb, :live_view

  alias WordleGame.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_new_game(socket)}
  end

  @impl true
  def handle_event("guess", %{"guess" => guess}, socket) do
    {updated_game, feedback} = Game.submit_guess(socket.assigns.game, guess)

    socket =
      socket
      |> assign(:game, updated_game)
      |> assign(:last_feedback, feedback)

    {:noreply, socket}
  end

  def handle_event("new_game", _, socket) do
    {:noreply, assign_new_game(socket)}
  end

  defp assign_new_game(socket) do
    secret = pick_secret_word()
    assign(socket, game: Game.new_game(secret), last_feedback: [])
  end

  defp pick_secret_word do
    words = [
      "ADIEU",
      "HELLO",
      "WORLD",
      "SWIFT",
      "ELIXIR",
      "FOCUS",
      "CRISP",
      "STRAY",
      "HOUSE",
      "PLANT"
    ]

    Enum.random(words)
  end
end
