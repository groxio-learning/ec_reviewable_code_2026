defmodule EcWordleWeb.Router do
  use EcWordleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EcWordleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EcWordleWeb do
    pipe_through :browser

    live "/", GameLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", EcWordleWeb do
  #   pipe_through :api
  # end
end
