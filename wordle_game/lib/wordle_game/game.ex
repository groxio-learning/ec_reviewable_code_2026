defmodule WordleGame.Game do
  defstruct [:secret, :guesses, :status]

  def new_game(secret) do
    %__MODULE__{
      secret: String.upcase(secret),
      guesses: [],
      status: :playing
    }
  end

  def submit_guess(%__MODULE__{status: status} = game, _guess) when status != :playing do
    {game, []}
  end

  def submit_guess(%__MODULE__{secret: secret, guesses: guesses} = game, guess) do
    guess_upper = String.upcase(guess)
    feedback = compute_feedback(secret, guess_upper)
    new_guesses = guesses ++ [guess_upper]
    new_status = determine_status(secret, guess_upper, new_guesses)

    updated_game = %{game | guesses: new_guesses, status: new_status}
    {updated_game, feedback}
  end

  defp compute_feedback(secret, guess) do
    secret_chars = String.graphemes(secret)
    guess_chars = String.graphemes(guess)

    guess_chars
    |> Enum.with_index()
    |> Enum.map(fn {char, idx} ->
      case Enum.at(secret_chars, idx) do
        ^char -> :correct
        _ -> check_position(char, secret_chars, guess_chars)
      end
    end)
  end

  defp check_position(char, secret_chars, guess_chars) do
    char_count_secret = Enum.count(secret_chars, &(&1 == char))
    char_count_guess = Enum.count(guess_chars, &(&1 == char))

    if char_count_secret > 0 and char_count_guess > 0 do
      :wrong_position
    else
      :not_in_word
    end
  end

  defp determine_status(secret, guess, guesses) do
    cond do
      guess == secret -> :won
      length(guesses) >= 6 -> :lost
      true -> :playing
    end
  end
end
