defmodule BtPositionWebUi.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      BtPositionWebUiWeb.Endpoint,
      {BtPositionWebUi.MQTT.Subscriber, []}
    ]

    opts = [strategy: :one_for_one, name: BtPositionWebUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BtPositionWebUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
