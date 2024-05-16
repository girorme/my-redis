defmodule Handler do
  @moduledoc """
  This genserver handle incoming requests from the client as messages
  """

  use GenServer
  require Logger

  @impl true
  def init(initial_state \\ %{socket: nil}) do
    state = Map.put(initial_state, :client_id, :rand.uniform(9999))
    Logger.info("[id: #{state.client_id}] Redis connection received... Waiting data")
    {:ok, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, %{client_id: client_id} = state) do
    Logger.info("[id: #{client_id}] Received: #{data}")
    :gen_tcp.send(socket, "+PONG\r\n")
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, %{client_id: client_id} = state) do
    Logger.info("[id: #{client_id}] Closing connection...")
    :gen_tcp.send(socket, "+PONG\r\n")
    {:noreply, state}
  end
end
