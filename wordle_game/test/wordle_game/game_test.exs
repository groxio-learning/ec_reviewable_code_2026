defmodule WordleGame.GameTest do
  use ExUnit.Case

  alias WordleGame.Game

  describe "new_game/1" do
    test "creates a new game with secret word and empty guesses" do
      game = Game.new_game("HELLO")

      assert game.secret == "HELLO"
      assert game.guesses == []
      assert game.status == :playing
    end
  end

  describe "submit_guess/2" do
    test "adds guess to game and returns feedback" do
      game = Game.new_game("HELLO")
      {updated_game, feedback} = Game.submit_guess(game, "GUARD")

      assert length(updated_game.guesses) == 1
      assert hd(updated_game.guesses) == "GUARD"
      assert is_list(feedback)
      assert length(feedback) == 5
    end

    test "returns :correct for exact letter matches" do
      game = Game.new_game("HELLO")
      {_game, feedback} = Game.submit_guess(game, "HELIX")

      assert Enum.at(feedback, 0) == :correct
      assert Enum.at(feedback, 1) == :correct
    end

    test "returns :wrong_position for letters in word but wrong spot" do
      game = Game.new_game("HELLO")
      {_game, feedback} = Game.submit_guess(game, "LLAMA")

      assert Enum.at(feedback, 0) == :wrong_position
      assert Enum.at(feedback, 1) == :wrong_position
    end

    test "returns :not_in_word for letters not in secret" do
      game = Game.new_game("HELLO")
      {_game, feedback} = Game.submit_guess(game, "GUMBY")

      assert Enum.at(feedback, 0) == :not_in_word
      assert Enum.at(feedback, 1) == :not_in_word
      assert Enum.at(feedback, 2) == :not_in_word
      assert Enum.at(feedback, 3) == :not_in_word
      assert Enum.at(feedback, 4) == :not_in_word
    end

    test "marks game as won when guess matches secret" do
      game = Game.new_game("HELLO")
      {updated_game, _feedback} = Game.submit_guess(game, "HELLO")

      assert updated_game.status == :won
    end

    test "marks game as lost when max guesses reached" do
      game = Game.new_game("HELLO")

      game =
        Enum.reduce(1..6, game, fn _, acc ->
          {updated, _} = Game.submit_guess(acc, "GUMBY")
          updated
        end)

      assert game.status == :lost
    end

    test "prevents guessing after game is won" do
      game = Game.new_game("HELLO")
      {won_game, _} = Game.submit_guess(game, "HELLO")
      {same_game, _} = Game.submit_guess(won_game, "GUARD")

      assert same_game == won_game
    end

    test "prevents guessing after game is lost" do
      game = Game.new_game("HELLO")

      game =
        Enum.reduce(1..6, game, fn _, acc ->
          {updated, _} = Game.submit_guess(acc, "GUMBY")
          updated
        end)

      {same_game, _} = Game.submit_guess(game, "HELLO")

      assert same_game == game
    end
  end
end
