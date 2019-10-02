defmodule BtPositionWebUiWeb.PageController do
  use BtPositionWebUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
