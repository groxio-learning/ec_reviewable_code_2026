# ElixirConf USA Reviewable Code 2026

Environment setup for the remote ElixirConf USA training on Friday.

This is a hands-on class held over Google Meet. Please complete the setup below before class so that we can spend our time coding, collaborating, and reviewing code rather than installing tools.

## 1. Install the class tools

You will need:

- A browser that works with Google Meet
- A working camera and microphone
- Git: <https://git-scm.com/downloads>
- An editor you are comfortable using
- Elixir and Erlang/OTP
- Phoenix
- Livebook
- PostgreSQL
- A coding agent, such as Claude Code or Codex

We will use cameras during the class to improve communication and engagement. Test your camera, microphone, and Google Meet access before Friday.

## 2. Verify Elixir and Erlang/OTP

Install a current, Phoenix-compatible version of Elixir and Erlang/OTP. Follow the official Elixir installation guide for your operating system:

<https://elixir-lang.org/install.html>

Verify the installation:

```console
$ elixir --version
Erlang/OTP ...
Elixir ...
```

Both an Erlang/OTP version and an Elixir version should appear.

Observer is helpful but optional. To test it, start IEx and run:

```elixir
iex> :observer.start()
```

You should see the Observer window and an `:ok` return value.

## 3. Install and verify Phoenix

Install the Phoenix project generator:

```console
$ mix local.hex --force
$ mix archive.install hex phx_new --force
```

Verify that Phoenix is available:

```console
$ mix phx.new --version
Phoenix installer v...
```

If the installer reports missing build tools for web assets, follow the instructions it prints before class.

## 4. Install and verify Livebook

Install Livebook using the instructions for your operating system:

<https://livebook.dev/#install>

Start it:

```console
$ livebook server
```

Livebook will print a local URL containing a token. Open that URL in your browser and confirm that you can create and run a notebook. The token will be different on your machine.

## 5. Install and verify PostgreSQL

Install PostgreSQL using the package or application appropriate for your operating system:

<https://www.postgresql.org/download/>

Start the PostgreSQL service, then verify the client:

```console
$ psql --version
psql (PostgreSQL) ...
```

Confirm that you can connect to your local server:

```console
$ psql postgres
```

At the PostgreSQL prompt, exit with:

```text
\q
```

Keep the database username and password you configured. You will need them when Phoenix connects to the database.

## 6. Install and verify a coding agent

Install at least one terminal-based coding agent. Two suitable choices are:

- Claude Code: <https://docs.anthropic.com/en/docs/claude-code/setup>
- Codex: <https://developers.openai.com/codex/cli>

Follow the provider's setup instructions, authenticate, and verify that the agent starts successfully from a terminal. Make sure your account has enough access or usage available for the full class.

You may use another coding agent if it can inspect and edit a local Elixir project, run terminal commands, and help review changes.

## 7. Fork and clone this repository

1. Open <https://github.com/batate/ec_reviewable_code_2026>.
2. Click **Fork** and create a fork in your GitHub account.
3. On your fork, click **Code** and copy its clone URL.
4. Clone your fork and enter the repository:

```console
$ git clone <paste-your-fork-url>
$ cd ec_reviewable_code_2026
```

Verify that `origin` points to your fork:

```console
$ git remote -v
```

Add the class repository as `upstream`:

```console
$ git remote add upstream https://github.com/batate/ec_reviewable_code_2026.git
$ git remote -v
```

You should now have:

- `origin` pointing to your fork
- `upstream` pointing to the class repository

## 8. Send a setup pull request

Before class, update your local copy:

```console
$ git pull upstream main
```

Edit `pull-requests.md` and replace `Your Name Here` with your name. Then commit and push the change:

```console
$ git add pull-requests.md
$ git commit -m "Add my name"
$ git push origin main
```

Open your fork on GitHub and create a pull request back to the class repository.

Please do not leave setup until Friday. If any verification step fails, allow time to resolve it before this hands-on class begins.
