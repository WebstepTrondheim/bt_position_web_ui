defmodule BtPositionWebUiWeb.PageController do
  use BtPositionWebUiWeb, :controller

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, BtPositionWebUiWeb.PageView, session: %{})
  end
end
