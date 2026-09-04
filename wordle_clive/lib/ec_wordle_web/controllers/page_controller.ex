defmodule EcWordleWeb.PageController do
  use EcWordleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
