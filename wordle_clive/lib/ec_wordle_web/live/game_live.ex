defmodule EcWordleWeb.GameLive do
  use EcWordleWeb, :live_view

  @word_length 5
  @max_turns 6
  @answer "crane"

  @dictionary MapSet.new([
                "crane",
                "audio",
                "blush",
                "cider",
                "flame",
                "glory",
                "hover",
                "jumpy",
                "lucky",
                "mirth",
                "novel",
                "proud",
                "quiet",
                "rally",
                "sauce",
                "torch",
                "vivid",
                "waltz",
                "zesty"
              ])

  @impl true
  def mount(_params, _session, socket) do
    {:ok, new_game(socket)}
  end

  @impl true
  def handle_event("submit_guess", %{"guess" => guess}, socket) do
    guess = normalize_guess(guess)

    cond do
      socket.assigns.game_over ->
        {:noreply, socket}

      byte_size(guess) != @word_length ->
        {:noreply, put_flash(socket, :error, "Guesses must be 5 letters long.")}

      not MapSet.member?(@dictionary, guess) ->
        {:noreply, put_flash(socket, :error, "That word is not in the practice list.")}

      true ->
        turns = socket.assigns.turns ++ [score_guess(guess, @answer)]
        won = guess == @answer
        game_over = won or length(turns) >= @max_turns

        socket =
          socket
          |> assign(:turns, turns)
          |> assign(:last_guess, "")
          |> assign(:won, won)
          |> assign(:game_over, game_over)
          |> maybe_flash_result(won, game_over)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("restart", _params, socket) do
    {:noreply, socket |> clear_flash() |> new_game()}
  end

  defp new_game(socket) do
    assign(socket,
      page_title: "Wordle",
      answer: @answer,
      max_turns: @max_turns,
      turns: [],
      last_guess: "",
      won: false,
      game_over: false
    )
  end

  defp maybe_flash_result(socket, true, _game_over) do
    put_flash(socket, :info, "You solved it. The answer was #{@answer |> String.upcase()}.")
  end

  defp maybe_flash_result(socket, false, true) do
    put_flash(socket, :error, "Out of guesses. The answer was #{@answer |> String.upcase()}.")
  end

  defp maybe_flash_result(socket, _won, _game_over), do: socket

  defp normalize_guess(guess) when is_binary(guess) do
    guess
    |> String.trim()
    |> String.downcase()
  end

  defp score_guess(guess, answer) do
    answer_letters = String.graphemes(answer)
    guess_letters = String.graphemes(guess)

    counts =
      answer_letters
      |> Enum.frequencies()

    first_pass =
      Enum.zip(guess_letters, answer_letters)
      |> Enum.map(fn
        {letter, letter} ->
          {letter, :correct}

        {letter, _} ->
          {letter, :unknown}
      end)

    remaining_counts =
      first_pass
      |> Enum.reduce(counts, fn
        {letter, :correct}, acc -> Map.update!(acc, letter, &(&1 - 1))
        {_, :unknown}, acc -> acc
      end)

    Enum.zip(first_pass, answer_letters)
    |> Enum.map(fn
      {{letter, :correct}, _} ->
        {letter, :correct}

      {{letter, :unknown}, _} ->
        case Map.get(remaining_counts, letter, 0) do
          count when count > 0 ->
            {letter, :present}

          _ ->
            {letter, :absent}
        end
    end)
  end

  def letter_class(:correct), do: "bg-emerald-500 text-white border-emerald-400"
  def letter_class(:present), do: "bg-amber-400 text-slate-950 border-amber-300"
  def letter_class(:absent), do: "bg-slate-700 text-slate-100 border-slate-600"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <main class="min-h-screen bg-[radial-gradient(circle_at_top,_#17324d_0%,_#09111d_45%,_#04070d_100%)] text-slate-100">
      <section class="mx-auto flex min-h-screen max-w-5xl flex-col px-4 py-8 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between gap-4">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.35em] text-cyan-200/80">
              Phoenix LiveView
            </p>
            <h1 class="mt-2 text-4xl font-black tracking-tight sm:text-5xl">Wordle</h1>
          </div>
          <button
            type="button"
            phx-click="restart"
            class="rounded-full border border-cyan-300/30 bg-white/5 px-4 py-2 text-sm font-semibold text-cyan-50 transition hover:bg-white/10"
          >
            New game
          </button>
        </div>

        <div class="mt-8 grid gap-8 lg:grid-cols-[minmax(0,1fr)_18rem]">
          <div class="rounded-3xl border border-white/10 bg-white/5 p-4 shadow-2xl shadow-black/20 backdrop-blur-sm sm:p-6">
            <div class="grid gap-2">
              <%= for turn <- @turns do %>
                <div class="grid grid-cols-5 gap-2">
                  <%= for {letter, state} <- turn do %>
                    <div class={[
                      "flex aspect-square items-center justify-center rounded-2xl border text-2xl font-black uppercase shadow-lg shadow-black/10 sm:text-3xl",
                      letter_class(state)
                    ]}>
                      {letter}
                    </div>
                  <% end %>
                </div>
              <% end %>

              <%= for _ <- 1..(max(@max_turns - length(@turns), 0)) do %>
                <div class="grid grid-cols-5 gap-2">
                  <%= for _ <- 1..5 do %>
                    <div class="aspect-square rounded-2xl border border-white/10 bg-slate-950/40">
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>

            <div class="mt-6 rounded-2xl border border-white/10 bg-slate-950/40 p-4">
              <%= if @game_over do %>
                <p class="text-lg font-semibold">
                  <%= if @won do %>
                    You won in {length(@turns)} turn{if length(@turns) == 1, do: "", else: "s"}.
                  <% else %>
                    Game over. The answer was <span class="font-black uppercase text-cyan-200">{@answer}</span>.
                  <% end %>
                </p>
              <% else %>
                <p class="text-lg font-semibold">
                  Type a five-letter word from the practice list and submit your guess.
                </p>
              <% end %>
            </div>
          </div>

          <aside class="rounded-3xl border border-white/10 bg-white/5 p-4 shadow-2xl shadow-black/20 backdrop-blur-sm sm:p-6">
            <h2 class="text-sm font-bold uppercase tracking-[0.25em] text-cyan-200/80">
              How it works
            </h2>
            <ul class="mt-4 space-y-3 text-sm leading-6 text-slate-200/90">
              <li>Green means the letter is in the right place.</li>
              <li>Yellow means the letter is in the answer but elsewhere.</li>
              <li>Gray means the letter is not in the answer.</li>
              <li>You get 6 turns total.</li>
            </ul>

            <div class="mt-6 rounded-2xl border border-cyan-400/20 bg-cyan-400/10 p-4">
              <p class="text-xs font-semibold uppercase tracking-[0.25em] text-cyan-100/80">
                Practice words
              </p>
              <p class="mt-2 text-sm leading-6 text-cyan-50/90">
                Crane, audio, blush, cider, flame, glory, hover, jumpy, lucky, mirth, novel, proud, quiet, rally, sauce, torch, vivid, waltz, zesty.
              </p>
            </div>
          </aside>
        </div>

        <form phx-submit="submit_guess" class="mt-8 flex max-w-xl gap-3">
          <input
            type="text"
            name="guess"
            value={@last_guess}
            maxlength="5"
            minlength="5"
            autocomplete="off"
            autocapitalize="none"
            spellcheck="false"
            placeholder="crane"
            disabled={@game_over}
            class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-lg font-semibold uppercase tracking-[0.35em] text-slate-50 placeholder:text-slate-400 focus:border-cyan-300 focus:outline-none focus:ring-2 focus:ring-cyan-300/30 disabled:cursor-not-allowed disabled:opacity-50"
          />
          <button
            type="submit"
            disabled={@game_over}
            class="rounded-2xl bg-cyan-300 px-5 py-3 text-sm font-black uppercase tracking-[0.25em] text-slate-950 transition hover:bg-cyan-200 disabled:cursor-not-allowed disabled:opacity-50"
          >
            Guess
          </button>
        </form>
      </section>
    </main>
    """
  end
end
