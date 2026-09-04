defmodule WordlexWeb.PageController do
  use WordlexWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
