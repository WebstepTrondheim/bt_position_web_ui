defmodule BtPositionWebUiWeb.WelcomeLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h1 style="margin-top: auto; flex-grow: 1; ">Welfare Dashboard</h1>
    <div class="dashboard">

      <%= for {device, parent} <- @list_of_devices do %>
        <div class="signal-card">
          <div class="wristband-container">
            <div class="wristband"></div>
              <div class="ring">
              <div class="alarm-button"> </div>
            </div>
            <div class="red"> </div>
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
    """
  end

  def mount(_session, socket) do
    Phoenix.PubSub.subscribe(
      BtPositionWebUi.PubSub,
      "device_update"
    )

    {:ok, assign(socket, list_of_devices: [], list_of_battery_status: [])}
  end

  def handle_info({:position_update, new_device}, socket) do
    list_of_devices = socket.assigns.list_of_devices

    new_list =
      Keyword.put(
        list_of_devices,
        new_device.device_id,
        new_device.closest_parent
      )
      |> Enum.sort_by(fn {device_id, _parent} -> device_id end)

    {:noreply, assign(socket, list_of_devices: new_list)}
  end

  def handle_info({:battery_update, %{device_id: device_id, charge_level: charge_level}}, socket) do
    has_low_battery? = charge_level < 20
    battery_list = socket.assigns.list_of_battery_status

    new_list =
      Keyword.put(battery_list, device_id, charge_level)
      |> IO.inspect()

    {:noreply, assign(socket, list_of_battery_status: new_list)}
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
