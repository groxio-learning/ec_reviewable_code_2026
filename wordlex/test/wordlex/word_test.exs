defmodule Wordlex.WordTest do
  use ExUnit.Case, async: true

  alias Wordlex.Word

  describe "new/1" do
    test "constructs a normalized word from trusted input" do
      # Arrange
      trusted_value = " crane "

      # Act
      word = Word.new(trusted_value)

      # Assert
      assert Word.value(word) == "CRANE"
      assert Word.letters(word) == ~w(C R A N E)
    end

    test "raises when trusted input violates the invariant" do
      # Arrange
      trusted_value = "six"

      # Act and Assert
      assert_raise ArgumentError, ~r/exactly five letters/, fn ->
        Word.new(trusted_value)
      end
    end
  end

  describe "parse/1" do
    test "parses and normalizes untrusted input" do
      # Arrange
      untrusted_value = " slate\n"

      # Act
      result = Word.parse(untrusted_value)

      # Assert
      assert {:ok, word} = result
      assert Word.value(word) == "SLATE"
    end

    test "rejects non-string input" do
      # Arrange
      untrusted_value = nil

      # Act
      result = Word.parse(untrusted_value)

      # Assert
      assert result == {:error, :not_a_string}
    end

    test "rejects a word with the wrong length" do
      # Arrange
      untrusted_value = "ELIXIR"

      # Act
      result = Word.parse(untrusted_value)

      # Assert
      assert result == {:error, :wrong_length}
    end

    test "rejects non-ASCII letters" do
      # Arrange
      untrusted_value = "AB1!?"

      # Act
      result = Word.parse(untrusted_value)

      # Assert
      assert result == {:error, :invalid_characters}
    end
  end
end
