defmodule Wordlex.Word do
  @moduledoc """
  A normalized five-letter word.

  This module is the smallest CRC boundary in the game: constructors establish
  the word invariant and converters expose values needed by other core modules.
  """

  @enforce_keys [:value]
  defstruct [:value]

  @opaque t :: %__MODULE__{value: String.t()}
  @type parse_error :: :not_a_string | :wrong_length | :invalid_characters

  @spec new(String.t()) :: t()
  def new(value) do
    case parse(value) do
      {:ok, word} -> word
      {:error, reason} -> raise ArgumentError, "invalid word: #{error_message(reason)}"
    end
  end

  @spec parse(term()) :: {:ok, t()} | {:error, parse_error()}
  def parse(value) when is_binary(value) do
    normalized = value |> String.trim() |> String.upcase()

    cond do
      String.length(normalized) != 5 -> {:error, :wrong_length}
      not String.match?(normalized, ~r/^[A-Z]{5}$/) -> {:error, :invalid_characters}
      true -> {:ok, %__MODULE__{value: normalized}}
    end
  end

  def parse(_value), do: {:error, :not_a_string}

  @spec value(t()) :: String.t()
  def value(%__MODULE__{value: value}), do: value

  @spec letters(t()) :: [String.t()]
  def letters(%__MODULE__{value: value}), do: String.graphemes(value)

  defp error_message(:not_a_string), do: "expected a string"
  defp error_message(:wrong_length), do: "expected exactly five letters"
  defp error_message(:invalid_characters), do: "expected only the letters A through Z"
end
