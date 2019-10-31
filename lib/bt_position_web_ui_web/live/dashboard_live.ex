defmodule BtPositionWebUiWeb.DashboardLive do
  use Phoenix.LiveView

  require Logger

  def render(assigns) do
    BtPositionWebUiWeb.PageView.render("dashboard.html", assigns)
  end

  def mount(_session, socket) do
    Phoenix.PubSub.subscribe(
      BtPositionWebUi.PubSub,
      "device_update"
    )

    Phoenix.PubSub.subscribe(
      BtPositionWebUi.PubSub,
      "position_update"
    )

    {:ok,
     assign(socket,
       device_list: [],
       battery_status_list: [],
       offline_devices_list: [],
       alarm_status_list: []
     )}
  end

  def handle_info({:position_update, new_device}, socket) do
    device_list = socket.assigns.device_list
    offline_devices = socket.assigns.offline_devices_list

    new_list =
      with device_id <- new_device["device_id"] |> String.to_atom(),
           parent_id <- new_device["parent_id"] |> String.to_atom(),
           do:
             Keyword.put(device_list, device_id, parent_id)
             |> Enum.sort_by(fn {device_id, _parent} -> device_id end)

    offline_devices =
      offline_devices
      |> Keyword.delete(new_device["device_id"] |> String.to_atom())

    {:noreply, assign(socket, device_list: new_list, offline_devices_list: offline_devices)}
  end

  def handle_info(
        {:battery_update, %{"device_id" => device_id, "charge_level" => charge_level}},
        socket
      ) do
    has_low_battery? = charge_level < 20
    battery_list = socket.assigns.battery_status_list

    new_list = Keyword.put(battery_list, device_id |> String.to_atom(), charge_level)

    {:noreply, assign(socket, battery_status_list: new_list)}
  end

  def handle_info(
        {:alarm_update, %{"device_id" => device_id, "alarm_status" => alarm_status}},
        socket
      ) do
    device_id = device_id |> String.to_atom()
    current_list = socket.assigns.alarm_status_list

    alarm_has_been_activated? =
      alarm_status and
        not Keyword.equal?(current_list, [{device_id, alarm_status}])

    alarm_list =
      case alarm_has_been_activated? do
        true ->
          Keyword.put(current_list, device_id, alarm_status)

        false ->
          current_list
      end

    {:noreply, assign(socket, alarm_status_list: alarm_list)}
  end

  def handle_info({:offline_update, %{"device_id" => device_id} = payload}, socket) do
    assigns = socket.assigns
    device_id = device_id |> String.to_atom()

    offline_list =
      assigns.offline_devices_list
      |> Keyword.put(device_id, payload)

    active_devices =
      assigns.device_list
      |> Keyword.delete(device_id)

    {:noreply, assign(socket, offline_devices_list: offline_list, device_list: active_devices)}
  end

  def get_battery_color(charge_level) do
    cond do
      charge_level < 20 ->
        "red"

      charge_level < 70 ->
        "yellow"

      charge_level == nil ->
        "yellow"

      true ->
        "hide"
    end
  end
end
