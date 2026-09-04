defmodule Wordlex.GameTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Wordlex.{Game, Word}

  describe "new/2 and view/1" do
    test "constructs an active six-attempt game without revealing the answer" do
      # Arrange
      answer = Word.new("CRANE")

      # Act
      presentation = answer |> Game.new() |> Game.view()

      # Assert
      assert presentation.status == :playing
      assert presentation.answer == nil
      assert presentation.attempts_remaining == 6
      assert presentation.can_guess?
      assert length(presentation.rows) == 6

      assert Enum.all?(presentation.rows, fn row ->
               length(row.tiles) == 5 and Enum.all?(row.tiles, &(&1.state == :empty))
             end)
    end

    test "rejects a non-positive attempt limit" do
      # Arrange
      answer = Word.new("CRANE")

      # Act and Assert
      assert_raise ArgumentError, ~r/positive integer/, fn ->
        Game.new(answer, max_attempts: 0)
      end
    end
  end

  describe "guess/2" do
    test "supports an uninterrupted construct-reduce-convert pipeline" do
      # Arrange
      answer = Word.new("CRANE")
      first_guess = Word.new("SLATE")
      second_guess = Word.new("CRANE")

      # Act
      presentation =
        answer
        |> Game.new()
        |> Game.guess(first_guess)
        |> Game.guess(second_guess)
        |> Game.view()

      # Assert
      assert presentation.status == :won
      assert presentation.answer == "CRANE"
      assert presentation.attempts_remaining == 4

      assert Enum.map(Enum.at(presentation.rows, 1).tiles, & &1.state) ==
               List.duplicate(:correct, 5)
    end

    test "scores repeated letters by consuming unmatched answer letters once" do
      # Arrange
      game = Game.new(Word.new("APPLE"))
      guess = Word.new("ALLEY")

      # Act
      presentation = game |> Game.guess(guess) |> Game.view()

      # Assert
      assert Enum.map(hd(presentation.rows).tiles, & &1.state) == [
               :correct,
               :present,
               :absent,
               :present,
               :absent
             ]
    end

    test "loses after six incorrect guesses and reveals the answer" do
      # Arrange
      game = Game.new(Word.new("CRANE"))
      guesses = ~w(SLATE ADIEU BRICK FJORD GUMBO NYMPH) |> Enum.map(&Word.new/1)

      # Act
      presentation = guesses |> Enum.reduce(game, &Game.guess(&2, &1)) |> Game.view()

      # Assert
      assert presentation.status == :lost
      assert presentation.answer == "CRANE"
      assert presentation.attempts_remaining == 0
      refute presentation.can_guess?
    end

    test "ignores guesses after the game is won" do
      # Arrange
      won_game = Game.new(Word.new("CRANE")) |> Game.guess(Word.new("CRANE"))

      # Act
      after_another_guess = Game.guess(won_game, Word.new("SLATE"))

      # Assert
      assert Game.view(after_another_guess) == Game.view(won_game)
      assert Game.finished?(after_another_guess)
    end

    test "keeps the strongest keyboard state across guesses" do
      # Arrange
      game = Game.new(Word.new("CRANE"))

      # Act
      presentation =
        game
        |> Game.guess(Word.new("CIVIC"))
        |> Game.guess(Word.new("ACORN"))
        |> Game.view()

      c_key = find_key(presentation, "C")
      i_key = find_key(presentation, "I")
      z_key = find_key(presentation, "Z")

      # Assert
      assert c_key.state == :correct
      assert i_key.state == :absent
      assert z_key.state == :unused
    end
  end

  property "reducers preserve game bounds and row shape" do
    check all(
            answer_value <- word_generator(),
            guess_values <- list_of(word_generator(), max_length: 20)
          ) do
      # Arrange
      game = Game.new(Word.new(answer_value))
      guesses = Enum.map(guess_values, &Word.new/1)

      # Act
      presentation = guesses |> Enum.reduce(game, &Game.guess(&2, &1)) |> Game.view()
      accepted_count = 6 - presentation.attempts_remaining

      # Assert
      assert accepted_count in 0..6
      assert length(presentation.rows) == 6
      assert Enum.all?(presentation.rows, &(length(&1.tiles) == 5))

      assert Enum.all?(presentation.rows, fn row ->
               Enum.all?(row.tiles, &(&1.state in [:empty, :absent, :present, :correct]))
             end)
    end
  end

  property "a terminal game is unchanged by every later guess" do
    check all(answer_value <- word_generator(), later_values <- list_of(word_generator())) do
      # Arrange
      answer = Word.new(answer_value)

      terminal_game =
        List.duplicate(Word.new("AAAAA"), 6)
        |> Enum.reduce(Game.new(answer), &Game.guess(&2, &1))

      later_guesses = Enum.map(later_values, &Word.new/1)

      # Act
      reduced_game = Enum.reduce(later_guesses, terminal_game, &Game.guess(&2, &1))

      # Assert
      assert Game.finished?(terminal_game)
      assert Game.view(reduced_game) == Game.view(terminal_game)
    end
  end

  property "scoring never consumes more occurrences than the answer contains" do
    check all(answer_value <- word_generator(), guess_value <- word_generator()) do
      # Arrange
      answer = Word.new(answer_value)
      game = Game.new(answer)

      # Act
      presentation = game |> Game.guess(Word.new(guess_value)) |> Game.view()
      scored_tiles = hd(presentation.rows).tiles

      # Assert
      for letter <- Enum.uniq(String.graphemes(guess_value)) do
        matched_count =
          Enum.count(scored_tiles, &(&1.letter == letter and &1.state in [:correct, :present]))

        available_count = Enum.count(String.graphemes(answer_value), &(&1 == letter))
        assert matched_count <= available_count
      end
    end
  end

  defp find_key(presentation, letter) do
    presentation.keyboard
    |> List.flatten()
    |> Enum.find(&(&1.letter == letter))
  end

  defp word_generator do
    ?A..?Z
    |> Enum.to_list()
    |> member_of()
    |> list_of(length: 5)
    |> map(&List.to_string/1)
  end
end
