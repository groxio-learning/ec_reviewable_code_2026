# Wordlex implementation plan

**Status:** Draft for review. No game implementation should begin until this plan is approved.

## 1. Goal

Build a polished, accessible Wordle-style game at `/` with Phoenix LiveView. A player gets six attempts to identify a five-letter word. Each accepted guess receives per-letter feedback:

- **Correct**: right letter, right position
- **Present**: right letter, wrong position
- **Absent**: no unmatched occurrence of the letter remains in the answer

The domain will follow the Construct-Reduce-Convert (CRC) pattern from `../SKILL.md`, with a pure functional core and an imperative LiveView shell.

## 2. Proposed scope and decisions for review

- Keep each game in LiveView memory; do not add persistence, accounts, or database tables.
- Replace the generated landing page with the game at `/`.
- Use five ASCII letters and six attempts.
- Normalize submitted words by trimming whitespace and uppercasing them.
- Vendor the complete canonical original Wordle corpus: 2,315 answers plus 10,657 supplemental accepted guesses (12,972 accepted words after union). Keep answers and supplemental guesses in separate normalized text files, and record their source, version, counts, and licensing/provenance alongside them.
- Treat every answer as an allowed guess and verify the corpus counts and set relationship in tests so the files cannot be silently truncated or corrupted.
- Choose answers randomly in the imperative shell. Make answer selection injectable so LiveView tests remain deterministic.
- Allow repeated guesses; a valid guess consumes an attempt even if it was submitted before.
- Reveal the answer only after a win or loss; do not render it into the page while a game is active.
- Include a read-only on-screen keyboard that clearly shows spent letters: unused letters remain neutral, absent letters become muted, and present/correct letters retain amber/green states. The strongest known result for each letter wins. Physical typing remains the primary input for the first version.
- Explain the game above the board in one short instruction block: “Guess the five-letter word in six tries. Correct letters are in the right spot, present letters are in the wrong spot, and absent letters are not in the word.” Pair this with the same visual and accessible state labels used by the board.
- Do not add authentication, multiplayer behavior, timers, statistics, hard mode, or daily-word scheduling in this iteration.

## 3. Architecture

### Functional core

The core contains no `Repo`, processes, randomness, clock access, I/O, or LiveView concerns.

#### `Wordlex.Word`

Owns a valid, normalized five-letter word.

| CRC category | Public API | Result |
|---|---|---|
| Construct | `new(value)` | Builds `t` from trusted input and raises on an invariant violation |
| Construct | `parse(value)` | Builds `{:ok, t}` or returns a specific validation error for untrusted form input |
| Convert | `value(word)` | Returns the normalized string |
| Convert | `letters(word)` | Returns its five graphemes |

Use an opaque struct-backed `t` so callers cannot casually bypass its invariant. `parse/1` is used once at the LiveView boundary; tagged tuples never enter a reducer pipeline.

#### `Wordlex.Dictionary`

Owns the answer collection and allowed-guess set.

| CRC category | Public API | Result |
|---|---|---|
| Construct | `new(answers, supplemental_guesses)` | Builds `t` from the trusted full corpus and enforces dictionary invariants |
| Convert | `allows?(dictionary, word)` | Reports whether a `Word.t()` is in the union of answers and supplemental guesses |
| Convert | `answers(dictionary)` | Returns the 2,315 candidate answers for the shell's picker |
| Convert | `counts(dictionary)` | Returns answer, supplemental-guess, and accepted-word counts for validation |

Dictionary construction will reject empty lists, malformed entries, duplicate entries within either source list, and overlap between the answer and supplemental-guess files. The loader/integrity tests will enforce the canonical counts, and the accepted set will always be their union. The core performs no file I/O or random selection.

#### `Wordlex.Game`

Owns the answer, accepted guesses, and maximum attempt count.

| CRC category | Public API | Result |
|---|---|---|
| Construct | `new(answer, opts \\ [])` | Builds a new `t`; `answer` is a `Word.t()` |
| Reduce | `guess(game, word)` | Returns `t`, always; records an allowed `Word.t()` only while play is active |
| Convert | `view(game)` | Returns the complete presentation model without exposing the active answer |
| Convert | `finished?(game)` | Returns whether the game is won or lost |

The primary use case remains an unbroken CRC pipeline:

```elixir
Game.new(answer)
|> Game.guess(first_guess)
|> Game.guess(second_guess)
|> Game.view()
```

`guess/2` never returns a tagged tuple or feedback tuple. Feedback is derived by `view/1`. The game enforces these invariants regardless of reducer call order:

- At most six guesses are retained.
- No guess is retained after a win or loss.
- Every retained guess is a valid `Word.t()`.
- Every rendered row contains exactly five tiles.
- The active answer is omitted from the presentation model until the game finishes.

Scoring will use a two-pass algorithm: mark exact matches and consume those answer positions first, then grade remaining letters against the remaining answer-letter counts. This prevents repeated letters from receiving too many **Present** results.

The presentation model returned by `view/1` will include padded board rows, status (`:playing`, `:won`, or `:lost`), attempts remaining, keyboard letter states, and an answer value only when finished. Status strength is `correct > present > absent`, so later keyboard calculations cannot downgrade a letter.

### Imperative shell

#### Dictionary loading

Add `Wordlex.DictionaryLoader` to read the two versioned files under `priv/wordlex/`, split and normalize their lines, and pass the raw collections to `Dictionary.new/2`. File access stays in this shell module rather than the CRC core. Start with straightforward loading in `mount/3`; use Tidewave `project_eval` to measure it with the full corpus and add application-level caching only if the measured cost warrants the extra state.

#### Answer selection

Define an `Wordlex.AnswerPicker` behaviour and a default `Wordlex.RandomAnswerPicker` implementation. Random selection occurs here, after converting the dictionary to answer candidates. Configure the picker through application configuration and provide a deterministic implementation under `test/support`.

This is deliberately outside the CRC core because randomness is an effect.

#### `WordlexWeb.GameLive`

The LiveView will:

1. Load and construct the full dictionary through `DictionaryLoader`, then request an answer from the configured picker in `mount/3`.
2. Construct a game and a `to_form/2` map form named `:play` with a `:word` field.
3. On submit, parse untrusted input with `Word.parse/1` and check it with `Dictionary.allows?/2`.
4. On success, pipe the existing game through `Game.guess/2`, then end with `Game.view/1` for rendering.
5. On invalid input, leave the game unchanged and rebuild the form with a field error; invalid input does not consume an attempt.
6. On `new_game`, ask the picker for another answer and start again with `Game.new/2`.

The LiveView may hold the opaque game and dictionary values, but it must not pattern-match on or reach into their structs. It consumes core decisions only through converters.

## 4. User interface

- Replace the generic Phoenix header and landing content with a focused Wordlex shell.
- Start the LiveView template with `<Layouts.app flash={@flash}>`.
- Place a concise “How to play” explanation above the board and keep it visible without dominating the game. Its wording must explain the six-try limit and all three feedback states without relying on color names alone.
- Render six stable board rows with five square tiles each.
- Give key elements stable IDs: `#wordlex-game`, `#game-board`, `#guess-form`, `#guess-word`, `#game-status`, `#attempts-remaining`, `#keyboard`, and `#new-game`.
- Use semantic labels and live regions. Tile and keyboard feedback must be conveyed by accessible text in addition to color.
- Use a restrained visual system with high-contrast green, amber, and neutral tile states, clear focus rings, balanced spacing, and subtle state transitions.
- Make the board usable at narrow mobile widths and centered without excessive empty space on desktop.
- Keep the input focused after accepted and rejected guesses where LiveView supports it cleanly.
- Render a QWERTY keyboard with a stable `#key-<letter>` ID and accessible state label for every key. A used/spent letter must visibly leave the neutral state; later guesses may upgrade it from absent to present or correct but never downgrade it.
- Disable guessing after completion and present an obvious new-game action.
- Use Tailwind utility classes and small custom CSS rules only where useful; do not build the game from daisyUI components and do not use `@apply`.
- Do not add inline scripts or a custom JavaScript hook unless browser validation proves one is necessary.

## 5. Testing strategy

Follow Arrange-Act-Assert explicitly in every test. Prefer small setup helpers that make those three phases visible rather than hiding behavior behind highly abstract helpers.

### Core example tests

Add async unit tests for:

- Trusted and untrusted word construction, normalization, and all rejection reasons.
- Dictionary construction and membership, including exact corpus counts (2,315 answers, 10,657 supplemental guesses, and 12,972 accepted words), uniqueness, normalization, and the answer-subset invariant.
- A fresh game's presentation model.
- Chained guesses as one CRC pipeline.
- Win and loss transitions.
- Ignoring guesses after terminal states.
- Attempts remaining and answer secrecy/reveal.
- Correct, present, and absent scoring.
- Repeated-letter cases, including an answer with one occurrence and a guess with multiple occurrences, and an answer with repeated occurrences.
- Keyboard state precedence across multiple guesses.

### Core property tests

Add `stream_data` as a test-only dependency and verify reducer invariants across generated sequences of valid words:

- Guess count never exceeds the configured maximum.
- Once terminal, any subsequent sequence of `guess/2` calls leaves the game unchanged.
- Every converted row always has five tiles and valid tile states.
- For each letter, `correct + present` never exceeds the number of occurrences available in the answer.

### LiveView tests

Use the configured deterministic picker and `Phoenix.LiveViewTest` to cover:

- Initial explanation, board, neutral keyboard, form, status, and attempts.
- Submission through `form("#guess-form", play: %{word: ...}) |> render_submit()` so tests validate real field names.
- Invalid shape and disallowed-word errors without consuming attempts.
- Accepted guesses updating the board and visibly marking every submitted letter as spent on the keyboard, with correct state precedence across later guesses.
- Winning and losing UI states, answer reveal, and disabled input.
- New-game reset.

Do not read LiveView assigns or core struct fields in integration tests; assert through rendered behavior and stable DOM IDs.

## 6. Tidewave-assisted workflow

Tidewave is part of both implementation and validation, not merely a final smoke test. Pi lacks native MCP registration, so use JSON-RPC calls to the running `http://localhost:4000/tidewave/mcp` endpoint through the shell when needed.

### Planning baseline already gathered

- `project_eval` confirmed Phoenix `1.8.13`, LiveView `1.2.11`, and the current controller-based `/` route.
- `get_docs` confirmed the installed `Phoenix.Component.to_form/2` map/error behavior.
- `get_docs` confirmed the installed `Phoenix.LiveViewTest.render_submit/2` guidance to submit through `form/3` rather than bypassing rendered inputs.
- `browser_eval` captured the current generated landing page and confirmed the Tidewave toolbar is injected.
- The baseline browser diagnostics included a failed dynamic import from Tidewave's hosted toolbar assets. Treat that as a pre-existing external diagnostic unless it remains reproducible and is shown to originate in application code.

### During implementation

1. Use `get_docs` before relying on Phoenix or LiveView APIs whose exact installed-version behavior is uncertain.
2. Use `get_source_location` to inspect generated or dependency implementation when documentation is insufficient.
3. After each core increment, use `project_eval` against the running application to exercise the real CRC pipeline and repeated-letter examples. This complements, but does not replace, ExUnit.
4. After wiring each LiveView event, use `browser_eval` snapshots before interacting; submit guesses through the actual form and verify visible transitions in one persistent browser session.
5. Use `get_logs` immediately after browser interactions to catch server exceptions, warnings, and unexpected event payloads.
6. Use `browser_eval` at approximately 375px mobile and 1280px desktop widths. Confirm the instructions remain succinct and visible, every submitted letter changes keyboard state, spent-letter states never regress, and the full keyboard remains usable at both widths; then run its accessibility report after the final markup is stable.
7. Re-run browser diagnostics after implementation and distinguish application regressions from the recorded Tidewave toolbar baseline issue.
8. `execute_sql_query` is not expected during feature work because this design adds no persistence. It may be used only to confirm that implementation did not create or depend on application tables.

## 7. Planned file changes

### Add

- `lib/wordlex/word.ex`
- `lib/wordlex/dictionary.ex`
- `lib/wordlex/game.ex`
- `lib/wordlex/dictionary_loader.ex`
- `lib/wordlex/answer_picker.ex`
- `lib/wordlex/random_answer_picker.ex`
- `lib/wordlex_web/live/game_live.ex`
- `lib/wordlex_web/live/game_live.html.heex`
- `test/wordlex/word_test.exs`
- `test/wordlex/dictionary_test.exs`
- `test/wordlex/game_test.exs`
- `test/wordlex_web/live/game_live_test.exs`
- `test/support/fixed_answer_picker.ex`
- `priv/wordlex/answers.txt` containing all 2,315 canonical answers
- `priv/wordlex/allowed_guesses.txt` containing all 10,657 canonical supplemental guesses
- `priv/wordlex/README.md` recording corpus provenance, version, expected counts, and update procedure

### Modify

- `mix.exs` and `mix.lock` for the test-only property-testing dependency.
- `config/config.exs` and `config/test.exs` for answer-picker injection.
- `lib/wordlex_web/router.ex` to route `/` to `GameLive`.
- `lib/wordlex_web/components/layouts.ex` and `layouts/root.html.heex` for Wordlex branding and page metadata.
- `assets/css/app.css` only for styles that are awkward to express as utilities.
- `README.md` with game behavior and run/test instructions.

### Remove after the LiveView route passes

- Generated `PageController`, `PageHTML`, home template, and their obsolete landing-page test.

No Ecto schema, migration, context, or repository change is planned.

## 8. Implementation order and review checkpoints

1. **Core contracts:** Add failing Word and Dictionary tests, then implement their constructors and converters.
2. **Game rules:** Add scoring and lifecycle tests, then implement `Game` with reducers returning only `t`.
3. **Invariant validation:** Add property tests and use Tidewave `project_eval` to exercise representative pipelines.
4. **Shell wiring:** Add deterministic picker configuration, LiveView behavior tests, route, and event handling.
5. **Presentation:** Build the board, keyboard, form, status states, responsive styling, and branding.
6. **Runtime validation:** Exercise complete win, loss, invalid input, and reset flows with Tidewave `browser_eval`; inspect `get_logs` and accessibility output.
7. **Cleanup:** Remove obsolete generated landing-page files and update documentation.
8. **Final verification:** Run `mix usage_rules.sync --check`, `mix format --check-formatted`, focused tests while iterating, and finally `mix precommit`. Re-run the Tidewave browser smoke test against the final server.

Pause for review after steps 2 and 4 if implementation reveals any pressure to break the CRC API or move domain decisions into the LiveView.

## 9. Acceptance criteria

- A player sees a succinct explanation of the goal, six-try limit, and all three feedback states before playing.
- A player can complete, lose, and restart a six-attempt game at `/` without a full page reload.
- Guess validation is clear and invalid guesses do not consume attempts.
- The accepted-guess dictionary contains the complete canonical 12,972-word original Wordle corpus, including all 2,315 possible answers, with provenance and integrity tests.
- Repeated-letter feedback follows Wordle's consumption rules.
- The QWERTY keyboard visibly and accessibly identifies all spent letters, preserves the strongest result for each letter, and remains neutral for letters not yet guessed.
- The answer is absent from rendered active-game markup and revealed only on completion.
- All functional-core public functions fit Construct, Reduce, or Convert; every reducer takes `t` first and returns only `t`.
- The main game flow is one uninterrupted pipe from constructor through reducers to converter.
- Core modules contain no effects, and random selection remains in an injectable shell.
- Example, property, and LiveView tests follow AAA and pass.
- Mobile, desktop, keyboard, color-independent feedback, and accessibility checks pass through Tidewave-assisted browser validation.
- `mix precommit` passes and Tidewave reports no new application-originated runtime errors.
