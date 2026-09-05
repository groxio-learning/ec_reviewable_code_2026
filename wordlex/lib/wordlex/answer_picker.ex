defmodule Wordlex.AnswerPicker do
  @moduledoc """
  Behaviour for the imperative shell that chooses a game's answer.
  """

  alias Wordlex.{Dictionary, Word}

  @callback pick(Dictionary.t()) :: Word.t()
end
