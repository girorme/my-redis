defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application

  require Logger

  def start(_type, _args) do
    port = 6379
    IO.puts("Starting redis server on port: #{port}")

    # # Since the tester restarts your program quite often, setting SO_REUSEADDR
    # # ensures that we don't run into 'Address already in use' errors
    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: true, reuseaddr: true])
    Supervisor.start_link([{Task, fn -> Server.accept(socket) end}], strategy: :one_for_one)
  end

  @doc """
  Listen for incoming connections
  """
  def accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        {:ok, pid} = GenServer.start(Handler, %{socket: client_socket})
        :gen_tcp.controlling_process(client_socket, pid)

      err ->
        Logger.error(err)
    end

    accept(socket)
  end
end
