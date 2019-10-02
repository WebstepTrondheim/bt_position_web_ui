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
          </div>
          <div class="information-container">
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
        </div>
      <% end %>

    </div>
    """
  end

  def mount(_session, socket) do
    Phoenix.PubSub.subscribe(
      BtPositionWebUi.PubSub,
      "position_update")
    {:ok, assign(socket, list_of_devices: [])}
  end

  def handle_info(new_device, socket) do
    new_list =
      Keyword.put(socket.assigns.list_of_devices, new_device.device_id, new_device.closest_parent)
    {:noreply, assign(socket, list_of_devices: new_list)}
  end
end
