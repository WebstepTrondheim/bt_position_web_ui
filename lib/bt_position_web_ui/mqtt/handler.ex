defmodule BtPositionWebUi.MQTT.Handler do
  @moduledoc """
  `MQTTHandler` is used by the `Tortoise` MQTT library to handle the incomming MQTT messages from the Bluetooth devices.
  """

  defstruct []
  alias __MODULE__, as: State

  require Logger

  def init(_opts) do
    Logger.info("Initializing RSSI handler")
    {:ok, %State{}}
  end

  def connection(:up, state) do
    Logger.info("Connection has been established")
    {:ok, state}
  end

  def connection(:down, state) do
    Logger.warn("Connection has been dropped")
    IO.inspect(state)
    {:ok, state}
  end

  def connection(:terminating, state) do
    Logger.warn("Connection is terminating")
    {:ok, state}
  end

  def subscription(:up, topic, state) do
    Logger.info("Subscribed to #{topic}")
    {:ok, state}
  end

  def subscription({:warn, [requested: req, accepted: qos]}, topic, state) do
    Logger.warn("Subscribed to #{topic}; requested #{req} but got accepted with QoS #{qos}")
    {:ok, state}
  end

  def subscription({:error, reason}, topic, state) do
    Logger.error("Error subscribing to #{topic}; #{inspect(reason)}")
    {:ok, state}
  end

  def subscription(:down, topic, state) do
    Logger.info("Unsubscribed from #{topic}")
    {:ok, state}
  end

  @doc """
  `handle_message/3` takes a list that matches a MQTT path, the payload of a message and the state of the `Handler`. By pattern matching the path we can have different versions handling specific kinds of messages.
  """
  def handle_message(["position", "device", device], payload, state) do
    with {:ok, data} <- Jason.decode(payload),
      do: Phoenix.PubSub.broadcast(BtPositionWebUi.PubSub, "device_update", {:position_update, data})

    {:ok, state}
  end


  def handle_message([ "battery", "device", device], payload, state) do
    {:ok, data} = Jason.decode(payload)
    with {:ok, data} <- Jason.decode(payload),
      do: Phoenix.PubSub.broadcast(BtPositionWebUi.PubSub, "device_update", {:battery_update, data})

    {:ok, state}
  end

  # catch-all clause
  # def handle_message(topic, publish, state) do
  #   Logger.info("#{Enum.join(topic, "/")} #{inspect(publish)}")
  #   {:ok, state}
  # end

  def terminate(reason, state) do
    Logger.warn("It's dead Jim!")
    IO.inspect(reason)
    IO.inspect(state)
  end
end
