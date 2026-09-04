defmodule WordleGameWeb.GameLiveTest do
  use WordleGameWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Game LiveView" do
    test "mounts with a new game", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/game")
      assert html =~ "Wordle"
    end

    test "displays guesses input", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/game")
      assert html =~ "Guess"
    end

    test "shows game board", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/game")
      assert html =~ "Guesses"
    end

    test "updates game state when guess is submitted", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/game")

      html =
        view
        |> form("#guess-form", %{"guess" => "HELLO"})
        |> render_submit()

      assert html =~ "HELLO"
    end

    test "displays feedback for submitted guesses", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/game")

      html =
        view
        |> form("#guess-form", %{"guess" => "HELLO"})
        |> render_submit()

      assert html =~ "bg-green-500" or html =~ "bg-yellow-500" or html =~ "bg-gray-400"
    end

    test "disables input when game is lost", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/game")

      render_submit(view, :guess, %{"guess" => "AAAAA"})
      render_submit(view, :guess, %{"guess" => "AAAAA"})
      render_submit(view, :guess, %{"guess" => "AAAAA"})
      render_submit(view, :guess, %{"guess" => "AAAAA"})
      render_submit(view, :guess, %{"guess" => "AAAAA"})
      html = render_submit(view, :guess, %{"guess" => "AAAAA"})

      assert html =~ "Game Over"
    end

    test "new game button resets the game", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/game")

      render_submit(view, :guess, %{"guess" => "HELLO"})
      html = render_click(view, :new_game)

      assert html =~ "Wordle"
      assert html =~ "6"
    end
  end
end
