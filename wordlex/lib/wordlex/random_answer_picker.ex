defmodule Wordlex.RandomAnswerPicker do
  @moduledoc """
  Chooses a random answer from a Wordlex dictionary.
  """

  @behaviour Wordlex.AnswerPicker

  alias Wordlex.Dictionary

  @impl true
  def pick(dictionary) do
    dictionary
    |> Dictionary.answers()
    |> Enum.random()
  end
end
