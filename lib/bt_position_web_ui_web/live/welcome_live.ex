defmodule BtPositionWebUiWeb.WelcomeLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h1 style="margin-top: auto; flex-grow: 1; ">Welfare Dashboard</h1>

    <%= if @list_of_devices |> Enum.count() > 0 do %>
    <h2 style="flex-grow: 1;">Online Devices</h2>
    <div class="dashboard">
      <div id="online-devices">
      <%= for {device, parent} <- @list_of_devices do %>
        <div class="signal-card">
          <div class="wristband-container">
            <div class="wristband"></div>
              <div class="ring">
                <div class="alarm-button"> </div>
              </div>
          </div>
          <div class="information-container">
            <div class="text-container">
              <div class="device-id">
                <%= device
                    |> Atom.to_string()
                    |> String.upcase() %>
              </div>
              <div class="small">is closest to</div>
              <div class="parent-id">
                <%= parent
                    |> Atom.to_string()
                    |> String.upcase() %>
              </div>
            </div>
            <div class="battery-container <%= @list_of_battery_status[device]
                                              |> get_battery_color() %>" >
              <%= if @list_of_battery_status
                     |> Keyword.has_key?(device) do %>
                <div class="">
                  Battery level <%= @list_of_battery_status[device] %>%
                </div>
              <% else %>
                <div>
                  Battery level not available
                </div>
              <% end %>
            </div>
          </div> <!-- end info container -->
        </div> <!-- end of signal card -->

      <% end %>
      </div>
      <%= else %>
        no online devices
      <% end %>

    <%= if @list_of_offline_devices |> Enum.count() > 0 do %>
      <h2>Offline devices</h2>
      <div id="offline-devices">
        <%= for {device_id, payload} <- @list_of_offline_devices do %>
        <div class="signal-card">
          <div class="wristband-container">
            <div class="wristband"></div>
              <div class="ring">
                <div class="alarm-button"> </div>
              </div>
          </div>
          <div class="information-container">
            <div class="text-container">
              <div class="device-id">
                <%= device_id
                    |> Atom.to_string()
                    |> String.upcase() %>
              </div>
              <div class="small">Last known position:</div>
              <div class="parent-id">
                <%= payload["last_signal"]["parent_id"]
                    |> String.upcase() %>
              </div>
              <div class="small">
                <%= payload["last_signal"]["time"] %>
              </div>
            </div>
          </div> <!-- end info container -->
        </div> <!-- end of signal card -->
        <% end %> <!-- list comp end -->
      </div>
    <% end %> <!-- end if -->
    </div> <!-- end dashboard -->

    """
  end

  def mount(_session, socket) do
    Phoenix.PubSub.subscribe(
      BtPositionWebUi.PubSub,
      "device_update"
    )

    {:ok, assign(socket, list_of_devices: [], list_of_battery_status: [], list_of_offline_devices: [])}
  end

  def handle_info({:position_update, new_device}, socket) do
    list_of_devices = socket.assigns.list_of_devices
    offline_devices = socket.assigns.list_of_offline_devices

    new_list =
      with device_id <- new_device["device_id"] |> String.to_atom(),
           parent_id <- new_device["parent_id"] |> String.to_atom(),
           do:
             Keyword.put(list_of_devices, device_id, parent_id)
             |> Enum.sort_by(fn {device_id, _parent} -> device_id end)

    offline_devices =
        offline_devices
        |> Keyword.delete(new_device["device_id"] |> String.to_atom())

    {:noreply, assign(socket, list_of_devices: new_list, list_of_offline_devices: offline_devices)}
  end

  def handle_info(
        {:battery_update, %{"device_id" => device_id, "charge_level" => charge_level}},
        socket
      ) do
    has_low_battery? = charge_level < 20
    battery_list = socket.assigns.list_of_battery_status

    new_list = Keyword.put(battery_list, device_id |> String.to_atom(), charge_level)

    {:noreply, assign(socket, list_of_battery_status: new_list)}
  end

  def handle_info({:offline_update, %{"device_id" => device_id} = payload}, socket) do
    assigns = socket.assigns
    device_id = device_id |> String.to_atom()

    offline_list =
      assigns.list_of_offline_devices
      |> Keyword.put(device_id, payload)

    active_devices =
      assigns.list_of_devices
      |> Keyword.delete(device_id)

    {:noreply, assign(socket, list_of_offline_devices: offline_list, list_of_devices: active_devices)}
  end

  defp get_battery_color(charge_level) do
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
