defmodule WordleGameWeb.PageController do
  use WordleGameWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
