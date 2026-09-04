# Wordlex

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

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
