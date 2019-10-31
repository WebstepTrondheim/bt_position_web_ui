defmodule BtPositionWebUiWeb.Router do
  use BtPositionWebUiWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :map do
    plug :put_layout, {BtPositionWebUiWeb.LayoutView, "maplayout.html"}
  end

  scope "/", BtPositionWebUiWeb do
    pipe_through :browser

    live "/", DashboardLive
    get "/old", PageController, :index
  end

  scope "/", BtPositionWebUiWeb do
    pipe_through [:browser, :map]

    get "/map", MapController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BtPositionWebUiWeb do
  #   pipe_through :api
  # end
end
