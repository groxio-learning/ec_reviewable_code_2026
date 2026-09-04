defmodule Wordlex.Dictionary do
  @moduledoc """
  The possible answers and supplemental accepted guesses for Wordlex.

  Construction is pure. Reading the vendored word files belongs to
  `Wordlex.DictionaryLoader`, outside this functional core.
  """

  alias Wordlex.Word

  @enforce_keys [:answers, :supplemental_guesses, :accepted]
  defstruct [:answers, :supplemental_guesses, :accepted]

  @opaque t :: %__MODULE__{
            answers: [Word.t()],
            supplemental_guesses: [Word.t()],
            accepted: MapSet.t(String.t())
          }

  @spec new([String.t()], [String.t()]) :: t()
  def new(answer_values, supplemental_values)
      when is_list(answer_values) and is_list(supplemental_values) do
    answers = build_words!(answer_values, :answers)
    supplemental_guesses = build_words!(supplemental_values, :supplemental_guesses)

    ensure_not_empty!(answers, :answers)
    ensure_not_empty!(supplemental_guesses, :supplemental_guesses)
    ensure_unique!(answers, :answers)
    ensure_unique!(supplemental_guesses, :supplemental_guesses)
    ensure_disjoint!(answers, supplemental_guesses)

    accepted =
      answers
      |> Enum.concat(supplemental_guesses)
      |> MapSet.new(&Word.value/1)

    %__MODULE__{
      answers: answers,
      supplemental_guesses: supplemental_guesses,
      accepted: accepted
    }
  end

  def new(_answer_values, _supplemental_values) do
    raise ArgumentError, "dictionary sources must be lists"
  end

  @spec allows?(t(), Word.t()) :: boolean()
  def allows?(%__MODULE__{accepted: accepted}, word) do
    MapSet.member?(accepted, Word.value(word))
  end

  @spec answers(t()) :: [Word.t()]
  def answers(%__MODULE__{answers: answers}), do: answers

  @spec counts(t()) :: %{
          answers: non_neg_integer(),
          supplemental_guesses: non_neg_integer(),
          accepted: non_neg_integer()
        }
  def counts(%__MODULE__{} = dictionary) do
    %{
      answers: length(dictionary.answers),
      supplemental_guesses: length(dictionary.supplemental_guesses),
      accepted: MapSet.size(dictionary.accepted)
    }
  end

  defp build_words!(values, source) do
    Enum.map(values, fn value ->
      try do
        Word.new(value)
      rescue
        ArgumentError ->
          raise ArgumentError, "#{source} contains an invalid word: #{inspect(value)}"
      end
    end)
  end

  defp ensure_not_empty!([], source), do: raise(ArgumentError, "#{source} cannot be empty")
  defp ensure_not_empty!(_words, _source), do: :ok

  defp ensure_unique!(words, source) do
    values = Enum.map(words, &Word.value/1)

    if length(values) != MapSet.size(MapSet.new(values)) do
      raise ArgumentError, "#{source} contains duplicate words"
    end
  end

  defp ensure_disjoint!(answers, supplemental_guesses) do
    answer_values = MapSet.new(answers, &Word.value/1)
    supplemental_values = MapSet.new(supplemental_guesses, &Word.value/1)

    unless MapSet.disjoint?(answer_values, supplemental_values) do
      raise ArgumentError, "answers and supplemental guesses must not overlap"
    end
  end
end
