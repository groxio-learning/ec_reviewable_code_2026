defmodule Wordlex.DictionaryLoader do
  @moduledoc """
  Loads the vendored Wordle corpus and constructs a `Wordlex.Dictionary`.
  """

  alias Wordlex.Dictionary

  @spec load!() :: Dictionary.t()
  def load! do
    priv_dir = :wordlex |> :code.priv_dir() |> to_string()

    answers = read_words!(Path.join([priv_dir, "wordlex", "answers.txt"]))
    supplemental_guesses = read_words!(Path.join([priv_dir, "wordlex", "allowed_guesses.txt"]))

    Dictionary.new(answers, supplemental_guesses)
  end

  defp read_words!(path) do
    path
    |> File.read!()
    |> String.split(~r/\R/, trim: true)
  end
end
