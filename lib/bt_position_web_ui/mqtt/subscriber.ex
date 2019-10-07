defmodule BtPositionWebUi.MQTT.Subscriber do
  use GenServer

  def start_link(params \\ {}) do
    GenServer.start_link(__MODULE__, params, name: :mqtt_subscriber)
  end

  @impl GenServer
  def init(_c) do
    with {:ok, pid} <- connect() do
      {:ok, pid}
    end
  end

  defp connect() do
    {:ok, _pid} =
      Tortoise.Connection.start_link(
        client_id: "bt-position-ui-subscriber",
        user_name: System.get_env("VELFERD_SUBSCRIBER_USER"),
        password: System.get_env("VELFERD_SUBSCRIBER_PWD"),
        server: {
          Tortoise.Transport.SSL,
          cacertfile: :certifi.cacertfile(), host: System.get_env("VELFERD_MQTT_HOST"), port: 8883
        },
        handler: {BtPositionWebUi.MQTT.Handler, []},
        subscriptions: ["position/#", "battery/#", "alarm/#", "offline/#"]
      )
  end
end
