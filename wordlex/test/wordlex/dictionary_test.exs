defmodule Wordlex.DictionaryTest do
  use ExUnit.Case, async: true

  alias Wordlex.{Dictionary, DictionaryLoader, Word}

  describe "new/2" do
    test "constructs a dictionary and accepts answers and supplemental guesses" do
      # Arrange
      answers = ["crane", "slate"]
      supplemental_guesses = ["adieu"]

      # Act
      dictionary = Dictionary.new(answers, supplemental_guesses)

      # Assert
      assert Dictionary.allows?(dictionary, Word.new("CRANE"))
      assert Dictionary.allows?(dictionary, Word.new("ADIEU"))
      refute Dictionary.allows?(dictionary, Word.new("ZZZZZ"))
      assert Dictionary.counts(dictionary) == %{answers: 2, supplemental_guesses: 1, accepted: 3}
    end

    test "rejects duplicate words after normalization" do
      # Arrange
      answers = ["crane", "CRANE"]
      supplemental_guesses = ["adieu"]

      # Act and Assert
      assert_raise ArgumentError, ~r/duplicate/, fn ->
        Dictionary.new(answers, supplemental_guesses)
      end
    end

    test "rejects overlap between answers and supplemental guesses" do
      # Arrange
      answers = ["crane"]
      supplemental_guesses = ["CRANE"]

      # Act and Assert
      assert_raise ArgumentError, ~r/must not overlap/, fn ->
        Dictionary.new(answers, supplemental_guesses)
      end
    end
  end

  describe "load!/0" do
    test "loads the complete canonical Wordle corpus" do
      # Arrange
      expected_counts = %{answers: 2_315, supplemental_guesses: 10_657, accepted: 12_972}

      # Act
      dictionary = DictionaryLoader.load!()
      answer_values = dictionary |> Dictionary.answers() |> Enum.map(&Word.value/1)

      # Assert
      assert Dictionary.counts(dictionary) == expected_counts
      assert length(answer_values) == length(Enum.uniq(answer_values))
      assert Enum.all?(answer_values, &Dictionary.allows?(dictionary, Word.new(&1)))
    end
  end
end
