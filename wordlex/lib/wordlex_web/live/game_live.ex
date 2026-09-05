defmodule WordlexWeb.GameLive do
  use WordlexWeb, :live_view

  alias Wordlex.{Dictionary, DictionaryLoader, Game, Word}

  @impl true
  def mount(_params, _session, socket) do
    dictionary = DictionaryLoader.load!()

    {:ok,
     socket
     |> assign(:dictionary, dictionary)
     |> start_new_game()}
  end

  @impl true
  def handle_event("guess", %{"play" => params}, socket) do
    case parse_guess(params["word"], socket.assigns.dictionary) do
      {:ok, word} ->
        game = Game.guess(socket.assigns.game, word)

        {:noreply,
         socket
         |> assign_game(game)
         |> assign_form()}

      {:error, message} ->
        {:noreply, assign_form(socket, params, message)}
    end
  end

  @impl true
  def handle_event("new_game", _params, socket) do
    {:noreply, start_new_game(socket)}
  end

  defp start_new_game(socket) do
    picker = Application.fetch_env!(:wordlex, :answer_picker)
    answer = picker.pick(socket.assigns.dictionary)

    socket
    |> assign_game(Game.new(answer))
    |> assign_form()
  end

  defp assign_game(socket, game) do
    socket
    |> assign(:game, game)
    |> assign(:game_view, Game.view(game))
  end

  defp assign_form(socket, params \\ %{"word" => ""}, error \\ nil)

  defp assign_form(socket, params, nil) do
    assign(socket, :form, to_form(params, as: :play))
  end

  defp assign_form(socket, params, error) do
    form = to_form(params, as: :play, errors: [word: {error, []}], action: :validate)
    assign(socket, :form, form)
  end

  defp parse_guess(value, dictionary) do
    with {:ok, word} <- Word.parse(value),
         true <- Dictionary.allows?(dictionary, word) do
      {:ok, word}
    else
      {:error, :not_a_string} -> {:error, "Enter a five-letter word."}
      {:error, :wrong_length} -> {:error, "Your guess must be exactly five letters."}
      {:error, :invalid_characters} -> {:error, "Use only the letters A through Z."}
      false -> {:error, "That word is not in the Wordlex dictionary."}
    end
  end

  defp tile_classes(:empty),
    do: "border-stone-300 bg-white/70 text-stone-900 dark:border-stone-600 dark:bg-stone-900/60"

  defp tile_classes(:absent),
    do: "border-stone-600 bg-stone-600 text-white dark:border-stone-500 dark:bg-stone-600"

  defp tile_classes(:present),
    do: "border-amber-500 bg-amber-500 text-stone-950 dark:border-amber-400 dark:bg-amber-400"

  defp tile_classes(:correct),
    do: "border-emerald-600 bg-emerald-600 text-white dark:border-emerald-500 dark:bg-emerald-500"

  defp key_classes(:unused),
    do:
      "border-stone-300 bg-stone-200 text-stone-800 dark:border-stone-600 dark:bg-stone-700 dark:text-stone-100"

  defp key_classes(:absent),
    do:
      "border-stone-500 bg-stone-600 text-stone-200 opacity-55 dark:border-stone-700 dark:bg-stone-800"

  defp key_classes(:present),
    do: "border-amber-500 bg-amber-500 text-stone-950 dark:border-amber-400 dark:bg-amber-400"

  defp key_classes(:correct),
    do: "border-emerald-600 bg-emerald-600 text-white dark:border-emerald-500 dark:bg-emerald-500"
end
