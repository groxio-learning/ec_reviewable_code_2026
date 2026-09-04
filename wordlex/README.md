# Wordlex

Wordlex is a Wordle-style Phoenix LiveView game. Guess a five-letter word in six tries and use the board and spent-letter keyboard to narrow down the answer. It includes the complete canonical original Wordle corpus: 2,315 answers and 10,657 supplemental guesses.

The game uses a pure Construct-Reduce-Convert functional core with LiveView and random answer selection in the imperative shell. Games live only for the lifetime of a LiveView connection; no game data is persisted.

To start your Phoenix server:

* Run `mix setup` to install and set up dependencies
* Start Phoenix with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Visit [`localhost:4000`](http://localhost:4000) to play.

Run the test and quality suite with:

```console
$ mix precommit
```

## Development tools

[Tidewave](https://tidewave.hexdocs.pm/welcome.html) is enabled in development. Connect an MCP client to [`http://localhost:4000/tidewave/mcp`](http://localhost:4000/tidewave/mcp) while the server is running.

[UsageRules](https://github.com/ash-project/usage_rules) manages the dependency guidance in `AGENTS.md`. After changing dependencies, refresh it with:

```console
$ mix usage_rules.sync
```

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
