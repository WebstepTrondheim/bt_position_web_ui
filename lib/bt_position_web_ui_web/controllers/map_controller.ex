defmodule BtPositionWebUiWeb.MapController do
  use BtPositionWebUiWeb, :controller

  def index(conn, _params) do
    render(conn, "map.html")
  end
end
