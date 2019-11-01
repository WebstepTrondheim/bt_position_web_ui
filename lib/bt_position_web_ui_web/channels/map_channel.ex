defmodule BtPositionWebUiWeb.MapChannel do
  use BtPositionWebUiWeb, :channel

  require Logger

  # Subscribe to pubsub

  def join("map:lobby", _payload, socket) do
    send(self(), :joined_lobby)
    send(self(), :init)

    {:ok, socket}
  end

  def handle_info(:init, socket) do
    Phoenix.PubSub.subscribe(
      BtPositionWebUi.PubSub,
      "position_update"
    )

    {:noreply, socket}
  end

  def handle_info(:joined_lobby, socket) do
    update_lists(socket)
  end

  # Getting data from pub-sub
  def handle_info({:position_update, new_device}, socket) do
    # Logger.info("Got data from pubsub: #{inspect(new_device)}")
    send(self(), {:ws_position_update, new_device})
    # send meaasge to be handled by map-websocket
    {:noreply, socket}
  end

  def handle_info({:device_update, data}, socket) do
    # Logger.info("Got data from pubsub: #{inspect(new_device)}")
    send(self(), {:ws_alarm_update, data})
    # send meaasge to be handled by map-websocket
    {:noreply, socket}
  end

  # Send data to websocket
  def handle_info({:ws_position_update, new_device}, socket) do
    # Logger.info("Sending data to websocket: #{inspect(new_device)}")
    device = Jason.encode!(new_device)
    broadcast!(socket, "update_positions", %{device_position: device})
    {:noreply, socket}
  end

  def handle_info({:ws_alarm_update, data}, socket) do
    data = Jason.encode!(data)
    broadcast!(socket, "update_alarm", %{device_alarm: data})
    {:noreply, socket}
  end

  @doc """
  Convinience function for updating the list of active map markers.

  Used when joining the lobby and when a new marker is created.
  """
  defp update_lists(socket) do
    # markers = get_markers() TODO: impelment
    broadcast!(socket, "update_lists", %{active_markers: []})
    {:noreply, socket}
  end
end
