defmodule Wordlex.Game do
  @moduledoc """
  The pure functional core of a Wordlex game.

  `new/2` constructs a game, `guess/2` reduces one game into another, and
  converters expose decisions and presentation data to the LiveView shell.
  """

  alias Wordlex.Word

  @default_max_attempts 6
  @keyboard_rows [~w(Q W E R T Y U I O P), ~w(A S D F G H J K L), ~w(Z X C V B N M)]
  @state_rank %{unused: 0, absent: 1, present: 2, correct: 3}

  @enforce_keys [:answer, :max_attempts]
  defstruct answer: nil, guesses: [], max_attempts: @default_max_attempts

  @opaque t :: %__MODULE__{
            answer: Word.t(),
            guesses: [Word.t()],
            max_attempts: pos_integer()
          }

  @type tile_state :: :empty | :absent | :present | :correct
  @type status :: :playing | :won | :lost

  @spec new(Word.t(), keyword()) :: t()
  def new(answer, opts \\ []) do
    Word.value(answer)
    max_attempts = Keyword.get(opts, :max_attempts, @default_max_attempts)

    unless is_integer(max_attempts) and max_attempts > 0 do
      raise ArgumentError, ":max_attempts must be a positive integer"
    end

    %__MODULE__{answer: answer, max_attempts: max_attempts}
  end

  @spec guess(t(), Word.t()) :: t()
  def guess(%__MODULE__{} = game, word) do
    Word.value(word)

    case status(game) do
      :playing -> %{game | guesses: [word | game.guesses]}
      _finished -> game
    end
  end

  @spec view(t()) :: map()
  def view(%__MODULE__{} = game) do
    status = status(game)
    scored_rows = scored_rows(game)

    %{
      answer: revealed_answer(game, status),
      attempts_remaining: game.max_attempts - length(game.guesses),
      can_guess?: status == :playing,
      keyboard: keyboard(scored_rows),
      rows: pad_rows(scored_rows, game.max_attempts),
      status: status,
      status_message: status_message(status)
    }
  end

  @spec finished?(t()) :: boolean()
  def finished?(%__MODULE__{} = game), do: status(game) != :playing

  defp status(%__MODULE__{} = game) do
    cond do
      Enum.any?(game.guesses, &(Word.value(&1) == Word.value(game.answer))) -> :won
      length(game.guesses) >= game.max_attempts -> :lost
      true -> :playing
    end
  end

  defp scored_rows(game) do
    game.guesses
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {guess, index} ->
      %{index: index, tiles: score(game.answer, guess)}
    end)
  end

  defp score(answer, guess) do
    answer_letters = Word.letters(answer)
    guess_letters = Word.letters(guess)

    exact_positions =
      answer_letters
      |> Enum.zip(guess_letters)
      |> Enum.with_index()
      |> Enum.reduce(MapSet.new(), fn
        {{letter, letter}, index}, positions -> MapSet.put(positions, index)
        {_different_letters, _index}, positions -> positions
      end)

    remaining_counts =
      answer_letters
      |> Enum.with_index()
      |> Enum.reject(fn {_letter, index} -> MapSet.member?(exact_positions, index) end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.frequencies()

    {tiles, _remaining_counts} =
      guess_letters
      |> Enum.with_index()
      |> Enum.map_reduce(remaining_counts, fn {letter, index}, counts ->
        score_letter(letter, index, exact_positions, counts)
      end)

    tiles
  end

  defp score_letter(letter, index, exact_positions, counts) do
    cond do
      MapSet.member?(exact_positions, index) ->
        {tile(letter, :correct), counts}

      Map.get(counts, letter, 0) > 0 ->
        {tile(letter, :present), Map.update!(counts, letter, &(&1 - 1))}

      true ->
        {tile(letter, :absent), counts}
    end
  end

  defp tile(letter, state) do
    %{letter: letter, state: state, label: "#{letter}: #{state_label(state)}"}
  end

  defp empty_tile, do: %{letter: "", state: :empty, label: "Empty tile"}

  defp pad_rows(scored_rows, max_attempts) do
    empty_rows =
      :empty
      |> List.duplicate(max_attempts - length(scored_rows))
      |> Enum.with_index(length(scored_rows) + 1)
      |> Enum.map(fn {_empty, index} ->
        %{index: index, tiles: List.duplicate(empty_tile(), 5)}
      end)

    scored_rows ++ empty_rows
  end

  defp keyboard(scored_rows) do
    known_states =
      scored_rows
      |> Enum.flat_map(& &1.tiles)
      |> Enum.reduce(%{}, fn tile, states ->
        Map.update(states, tile.letter, tile.state, &stronger_state(&1, tile.state))
      end)

    Enum.map(@keyboard_rows, fn letters ->
      Enum.map(letters, fn letter ->
        state = Map.get(known_states, letter, :unused)
        %{letter: letter, state: state, label: "#{letter}: #{state_label(state)}"}
      end)
    end)
  end

  defp stronger_state(left, right) do
    if Map.fetch!(@state_rank, left) >= Map.fetch!(@state_rank, right), do: left, else: right
  end

  defp revealed_answer(_game, :playing), do: nil
  defp revealed_answer(game, _finished), do: Word.value(game.answer)

  defp status_message(:playing), do: "Keep going"
  defp status_message(:won), do: "Brilliant — you found it!"
  defp status_message(:lost), do: "Good try — the word was"

  defp state_label(:empty), do: "empty"
  defp state_label(:unused), do: "unused"
  defp state_label(:absent), do: "absent"
  defp state_label(:present), do: "present in another position"
  defp state_label(:correct), do: "correct position"
end
