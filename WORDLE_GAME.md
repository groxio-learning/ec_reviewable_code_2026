# Wordle Game - Phoenix LiveView Implementation

A fully functional Wordle game built with Phoenix LiveView using test-driven development (TDD).

## Overview

Players have 6 attempts to guess a 5-letter secret word. After each guess, they receive feedback:
- **Green**: Letter in correct position
- **Yellow**: Letter in word but wrong position
- **Gray**: Letter not in word

## Architecture

### Core Game Logic (`lib/wordle_game/game.ex`)
- **Game struct**: Maintains secret word, guesses list, and game status
- **new_game/1**: Initializes a new game with a secret word
- **submit_guess/2**: Processes a guess and returns feedback
- **Status tracking**: Automatically tracks win/loss conditions

### LiveView Component (`lib/wordle_game_web/live/game_live.ex`)
- Real-time game state updates
- Event handlers for guess submission and new game
- Random word selection from predefined word list

### User Interface (`lib/wordle_game_web/live/game_live.html.heex`)
- Responsive Tailwind CSS design
- Visual feedback with color-coded tiles
- Guess history display
- Game status messages
- Input validation and form submission

## Testing

### Test Coverage: 21 tests, 0 failures

**Game Logic Tests** (`test/wordle_game/game_test.exs`)
- Game initialization
- Guess submission and feedback
- Correct position detection
- Wrong position detection
- Not in word detection
- Win condition
- Loss condition (6 guesses limit)
- Input prevention after game end

**LiveView Tests** (`test/wordle_game_web/live/game_live_test.exs`)
- Component mounting
- Guess input display
- Game board rendering
- Game state updates
- Feedback visualization
- Input disabling on game end
- New game button functionality

## Running the Game

```bash
cd wordle_game
mix ecto.create        # Setup database (one-time)
mix phx.server         # Start Phoenix server
```

Visit `http://localhost:4000/game` in your browser to play.

## Technical Details

- **Framework**: Phoenix 1.8.13 with LiveView 1.2.11
- **Language**: Elixir
- **Testing**: ExUnit (async tests enabled)
- **Styling**: Tailwind CSS with DaisyUI
- **Database**: PostgreSQL (optional, not required for game)

## Development Notes

- Built following strict TDD methodology: failing test → minimal implementation → refactored code
- All game logic is pure functional code with no external dependencies
- LiveView handles all UI state synchronization automatically
- Code simplified by removing unused variables and consolidating logic
