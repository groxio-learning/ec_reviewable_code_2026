---
name: using-crc
description: Designs and reviews Elixir functional cores with the Construct-Reduce-Convert (CRC) pattern. Constructors build the module's type, reducers have the shape t -> t and chain through pipes, converters turn the type into something else. Use when writing or restructuring an Elixir domain module, designing a functional core, choosing a module's public API and function names, splitting core logic from a LiveView or GenServer, or reviewing Elixir for pipe-friendly design. Triggers even when the user does not say "CRC", including "functional core", "construct reduce convert", "make this pipeable", "design this module", "where should this logic live", and "is this idiomatic Elixir". Not for cyclic redundancy checks or CRC checksums.
metadata:
  version: "1.0"
---

# Using CRC

CRC sorts every public function in a module into one of three categories, and the
category fixes the signature. Apply it to the functional core, meaning the pure part of
a domain module. It does not apply to a LiveView, a GenServer, a controller, or a
context function that touches Ecto.

## The three categories

| Category | Signature | Job |
|---|---|---|
| Construct | `input -> t` | Build the module's type from raw input |
| Reduce | `t -> t` | Transform the type into the same type |
| Convert | `t -> other` | Turn the type into something for the outside world |

`t` is the module's own type, and it is always the first argument. That one convention
is what makes the pipe work. Everything else follows from it.

## Quick start

```elixir
defmodule Counter do
  defstruct count: 0, max: 100

  @type t :: %__MODULE__{count: integer(), max: integer()}

  # Construct
  @spec new(keyword()) :: t()
  def new(opts \\ []), do: struct!(__MODULE__, opts)

  # Reduce
  @spec add(t(), integer()) :: t()
  def add(%__MODULE__{} = counter, amount) do
    %{counter | count: min(counter.count + amount, counter.max)}
  end

  # Convert
  @spec show(t()) :: String.t()
  def show(%__MODULE__{} = counter), do: "#{counter.count} / #{counter.max}"
end

Counter.new(max: 10) |> Counter.add(3) |> Counter.add(4) |> Counter.show()
# => "7 / 10"
```

## The four rules

These decide whether a module is CRC or only looks like it.

1. **A reducer returns `t`, and nothing else.** No `{:ok, t}`, no `{t, metadata}`, no
   bare boolean. If a function needs to report something alongside the new state, put
   that something in the struct and add a converter to read it.
2. **`t` is the first argument** of every reducer and converter, so `|>` reaches it.
3. **Constructors run at the boundary, not mid-pipe.** Use `new/1` for trusted input,
   returning `t` directly. Use `parse/1` for untrusted input, returning
   `{:ok, t} | {:error, reason}`. Never put a tagged tuple in the middle of a pipeline.
4. **Converters end the pipe.** After a converter you hold a string, a map, or a
   boolean, and you cannot reduce further. That is the signal that the core is finished
   and the shell takes over.

Invariants belong inside the reducers. In the example above, `count` can never exceed
`max` no matter what order calls arrive in, so there is no separate validation step to
forget.

## Designing a module with CRC

1. Name the type first. Write `defstruct` and `@type t`. If you cannot name what the
   module holds, the module has no coherent job yet.
2. List the verbs the domain uses. Sort each one into construct, reduce, or convert.
3. Write the constructors. One `new/1` for trusted input. Add `parse/1` only when
   untrusted input actually reaches this module.
4. Write the reducers. Give each the shape `t -> t`. When a reducer wants to return
   extra information, add a field to the struct instead.
5. Write the converters. One per consumer need: a string for display, a map for JSON, a
   predicate for control flow.
6. Check that a realistic call site is a single unbroken pipe. If it needs a `case` or
   a `with` in the middle, a reducer is returning the wrong shape.

Start with primitives. A CRC module whose type is an integer or a map is correct and
common. Reach for a struct when the type has more than one field or needs enforced
invariants.

## Reviewing a module against CRC

Work through this in order. The first failure usually explains the rest.

- [ ] Does every public function have the module's type as its first argument?
- [ ] Does every reducer return `t`? Look hard for tuple returns.
- [ ] Can the main use case be written as one pipe?
- [ ] Do constructors appear only at the start of a pipeline?
- [ ] Does the caller reach into the struct with dot access or pattern matching where a
      converter should exist?
- [ ] Is anything impure in here? Look for `:rand`, `DateTime.utc_now/0`, `System`,
      `Repo`, `IO`, `Process`, and `send`.
- [ ] Do the names say what the function does, or do they say what the caller wanted?
      `new_game/1` and `submit_guess/2` are shell verbs. `new/1` and `guess/2` are core
      verbs.

## Anti-patterns

**A reducer that returns a tuple.** This is the most common break, and it is worth
recognizing on sight. From a real workshop module:

```elixir
# Broken: the reducer returns {t, feedback}, so it cannot be piped
def submit_guess(%__MODULE__{secret: secret, guesses: guesses} = game, guess) do
  feedback = compute_feedback(secret, guess)
  updated_game = %{game | guesses: guesses ++ [guess]}
  {updated_game, feedback}
end
```

The caller is now forced to destructure on every call, two guesses cannot chain, and
the feedback is lost unless the caller stores it. The fix moves the extra value into
the type and exposes it through a converter:

```elixir
# Fixed: reduce returns t, convert reads the derived value
@spec guess(t(), String.t()) :: t()
def guess(%__MODULE__{} = game, word) do
  %{game | guesses: game.guesses ++ [String.upcase(word)]}
end

@spec feedback(t()) :: [[:correct | :wrong_position | :not_in_word]]
def feedback(%__MODULE__{} = game) do
  Enum.map(game.guesses, &score(game.secret, &1))
end
```

Now `game |> Game.guess("crane") |> Game.guess("slate") |> Game.feedback()` works, and
history comes free because the guesses accumulate in the type.

**Impurity in the core.** A random word chosen inside `new/0`, or a timestamp read
inside a reducer, makes the module untestable without stubbing. Pass the value in:
`Game.new(secret: Dictionary.random_word())`, called from the shell.

**Reaching past the API.** When a LiveView writes `@game.status == :won`, a converter
is missing. Add `won?/1`.

**Tagged tuples mid-pipe.** `parse/1` returning `{:ok, t}` followed by more reducers
forces a `with` around every chain. Parse once at the boundary, then pipe freely.

**A GenServer holding logic that belongs in the core.** State in a process is not the
same as state in a type. Put the rules in a CRC module and let the process hold one
value of that type.

## Testing a CRC module

Reducers need no setup, no mocks, and no sandbox, so test them directly. Because
reducers are closed under the type, property-based tests fit well: generate a random
sequence of reducer calls and assert the invariants still hold. In the `Counter`
example, `count` stays within bounds for any sequence, and `add(n)` then `add(-n)` is
identity away from the bounds.

Converters get example-based tests. Constructors get one test per input shape,
including the failure shapes of `parse/1`.

## Where the core ends

The CRC module returns decisions and data. It never performs the effect. The shell
calls the core, then acts on what came back.

```elixir
# In the LiveView
def handle_event("guess", %{"word" => word}, socket) do
  game = Game.guess(socket.assigns.game, word)
  {:noreply, assign(socket, game: game, feedback: Game.feedback(game))}
end
```

If a reducer needs to write to the database or send a message, have it record the
intent in the type and let the shell read that with a converter and perform the effect.

## Success criteria

- [ ] Every public function is a constructor, a reducer, or a converter
- [ ] Every reducer has the signature `t -> t` with `t` first
- [ ] The primary use case reads as one unbroken pipe
- [ ] No `:rand`, no clock reads, no I/O, and no process calls in the module
- [ ] Callers use converters instead of reaching into the struct
- [ ] Reducer invariants hold under any call order, verified by a property test
