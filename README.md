# ElixirConf USA Reviewable Code 2026

Environment setup for the remote ElixirConf USA training on Friday.

This is a hands-on class held over Google Meet. Please complete the setup below before class so that we can spend our time coding, collaborating, and reviewing code rather than installing tools.

## 1. Install the class tools

You will need (instructions below):

- A browser that works with Google Meet
- A working camera and microphone
- Git: <https://git-scm.com/downloads>
- An editor you are comfortable using
- [Elixir and Erlang/OTP](https://elixir-lang.org/install.html)
- [Phoenix](https://hexdocs.pm/phoenix/installation.html)
- Livebook
- PostgreSQL
- A coding agent, such as Claude Code or Codex

We will use cameras during the class to improve communication and engagement. Test your camera, microphone, and Google Meet access before Friday.

## 2. Verify Elixir and Erlang/OTP

Install a current, Phoenix-compatible version of Elixir and Erlang/OTP. Follow the [official Elixir installation guide](https://elixir-lang.org/install.html) for your operating system.

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

Follow the [official Phoenix installation guide](https://hexdocs.pm/phoenix/installation.html), including its prerequisites, and install the Phoenix project generator:

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

## 7. Fork this repository

Fork the class repository into your own GitHub account. **Do not clone the class repository directly.** First create your fork on GitHub, and then clone your fork to your computer.

1. Open <https://github.com/groxio-learning/ec_reviewable_code_2026>.
2. Click **Fork** and create a fork in your GitHub account.
3. Confirm that GitHub has taken you to the new repository under your own account.
4. On your fork, click **Code** and copy its clone URL.
5. Clone your fork—not the class repository—and enter it:

```console
$ git clone <paste-your-fork-url>
$ cd ec_reviewable_code_2026
```

Verify that `origin` points to your fork:

```console
$ git remote -v
origin  https://github.com/your-github-user/ec_reviewable_code_2026.git (fetch)
origin  https://github.com/your-github-user/ec_reviewable_code_2026.git (push)
```

If `origin` contains `groxio-learning` instead of your GitHub username, you cloned the class repository rather than your fork. Go back to your fork on GitHub, copy its URL, and clone that repository instead.

Add the class repository as `upstream`:

```console
$ git remote add upstream https://github.com/groxio-learning/ec_reviewable_code_2026.git
$ git remote -v
```

The output should show both remotes:

```console
origin    https://github.com/your-github-user/ec_reviewable_code_2026.git (fetch)
origin    https://github.com/your-github-user/ec_reviewable_code_2026.git (push)
upstream  https://github.com/groxio-learning/ec_reviewable_code_2026.git (fetch)
upstream  https://github.com/groxio-learning/ec_reviewable_code_2026.git (push)
```

Your `origin` URL may use either HTTPS (`https://github.com/...`) or SSH (`git@github.com:...`). Both are correct as long as `origin` names your GitHub account and `upstream` names `groxio-learning`.

## 8. Send a setup pull request

Before class, update your local copy:

```console
$ git pull --ff-only upstream main
```

Edit `pull-requests.md` and replace `Your Name Here` with your name. Then commit and push the change:

```console
$ git add pull-requests.md
$ git commit -m "Add my name"
$ git push origin main
```

Open your fork on GitHub and create a pull request back to the class repository.

## 9. Confirm that setup is complete

Run these commands from your local `ec_reviewable_code_2026` directory:

```console
$ git remote get-url origin
https://github.com/your-github-user/ec_reviewable_code_2026.git

$ git remote get-url upstream
https://github.com/groxio-learning/ec_reviewable_code_2026.git

$ git status
On branch main
Your branch is up to date with 'origin/main'.
```

Your setup is complete when:

- The repository is forked into your GitHub account.
- Your local checkout was cloned from your fork.
- `origin` points to your fork.
- `upstream` points to the class repository owned by `groxio-learning`.
- Your name change is committed and pushed to your fork.
- You have opened a pull request from your fork to the class repository.

Please do not leave setup until Friday. If any verification step fails, allow time to resolve it before this hands-on class begins.
