defmodule WordlexWeb.GameLiveTest do
  use WordlexWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "gameplay" do
    test "shows the instructions, an empty board, and a neutral keyboard", %{conn: conn} do
      # Arrange and Act
      {:ok, view, _html} = live(conn, ~p"/")

      # Assert
      assert has_element?(view, "#wordlex-game")
      assert has_element?(view, "#how-to-play", "Guess the five-letter word in six tries")
      assert has_element?(view, "#game-board")
      assert has_element?(view, "#tile-1-1[data-state=empty]")
      assert has_element?(view, "#guess-form")
      assert has_element?(view, "#key-q[data-state=unused]")
      assert has_element?(view, "#key-z[data-state=unused]")
      refute has_element?(view, "#revealed-answer")
    end

    test "rejects a malformed guess without consuming an attempt", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")

      # Act
      view
      |> form("#guess-form", play: %{word: "six"})
      |> render_submit()

      # Assert
      assert has_element?(view, "#guess-form", "exactly five letters")
      assert has_element?(view, "#attempts-remaining", "6 tries left")
      assert has_element?(view, "#tile-1-1[data-state=empty]")
    end

    test "rejects a five-letter word outside the dictionary", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")

      # Act
      view
      |> form("#guess-form", play: %{word: "ZZZZZ"})
      |> render_submit()

      # Assert
      assert has_element?(view, "#guess-form", "not in the Wordlex dictionary")
      assert has_element?(view, "#attempts-remaining", "6 tries left")
      assert has_element?(view, "#key-z[data-state=unused]")
    end

    test "accepts a guess and marks its letters as spent", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")

      # Act
      view
      |> form("#guess-form", play: %{word: "SLATE"})
      |> render_submit()

      # Assert
      assert has_element?(view, "#tile-1-1[data-state=absent]", "S")
      assert has_element?(view, "#tile-1-3[data-state=correct]", "A")
      assert has_element?(view, "#tile-1-5[data-state=correct]", "E")
      assert has_element?(view, "#key-s[data-state=absent]")
      assert has_element?(view, "#key-a[data-state=correct]")
      assert has_element?(view, "#key-e[data-state=correct]")
      assert has_element?(view, "#attempts-remaining", "5 tries left")
    end

    test "never downgrades a spent letter's keyboard state", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#guess-form", play: %{word: "CIVIC"})
      |> render_submit()

      # Act
      view
      |> form("#guess-form", play: %{word: "ACORN"})
      |> render_submit()

      # Assert
      assert has_element?(view, "#key-c[data-state=correct]")
      assert has_element?(view, "#key-i[data-state=absent]")
    end

    test "wins, reveals the answer, and disables guessing", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")

      # Act
      view
      |> form("#guess-form", play: %{word: "CRANE"})
      |> render_submit()

      # Assert
      assert has_element?(view, "#game-status[data-status=won]")
      assert has_element?(view, "#revealed-answer", "CRANE")
      assert has_element?(view, "#guess-word[disabled]")
      assert has_element?(view, "#submit-guess[disabled]")
    end

    test "loses after six accepted guesses", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")
      guesses = ~w(SLATE ADIEU BRICK FJORD GUMBO NYMPH)

      # Act
      Enum.each(guesses, fn guess ->
        view
        |> form("#guess-form", play: %{word: guess})
        |> render_submit()
      end)

      # Assert
      assert has_element?(view, "#game-status[data-status=lost]")
      assert has_element?(view, "#revealed-answer", "CRANE")
      assert has_element?(view, "#attempts-remaining", "0 tries left")
      assert has_element?(view, "#guess-word[disabled]")
    end

    test "starts a fresh game", %{conn: conn} do
      # Arrange
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#guess-form", play: %{word: "CRANE"})
      |> render_submit()

      # Act
      view |> element("#new-game") |> render_click()

      # Assert
      assert has_element?(view, "#game-status[data-status=playing]")
      assert has_element?(view, "#attempts-remaining", "6 tries left")
      assert has_element?(view, "#tile-1-1[data-state=empty]")
      assert has_element?(view, "#key-c[data-state=unused]")
      refute has_element?(view, "#revealed-answer")
    end
  end
end
