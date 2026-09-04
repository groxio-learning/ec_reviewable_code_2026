defmodule Wordlex.FixedAnswerPicker do
  @moduledoc false

  @behaviour Wordlex.AnswerPicker

  alias Wordlex.{Dictionary, Word}

  @answer "CRANE"

  @impl true
  def pick(dictionary) do
    Enum.find(Dictionary.answers(dictionary), &(Word.value(&1) == @answer))
  end
end
