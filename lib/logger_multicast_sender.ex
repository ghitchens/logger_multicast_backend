defmodule LoggerMulticastSender do

  @moduledoc false

  use GenServer
  require Logger

  @socket_retry_time  1000      # milliseconds between port open attempts
  @packet_pacer_time  10        # milliseconds between multicasts
  @queue_size         1024      # maximum lines to save in the queue

  @socket_opts [:binary, {:broadcast, true}, {:active, false}, {:reuseaddr, true} ]

  def init(target) do
    Logger.debug "started multicast logging sender on target: #{inspect target}"
    state = %{target: target, queue: [], socket: nil}
    {:ok, state}
  end

  def handle_cast({:add_entry, entry}, state) do
    queue = state.queue ++ [entry]
    if (length(queue) > @queue_size) do
      [_ | queue_tail] = queue
      {:noreply, %{ state | queue: queue_tail}, @packet_pacer_time}
    else
      {:noreply, %{ state | queue: queue}, @packet_pacer_time}
    end
  end

  # "handle a timer with no current socket - attempt to open it"
  def handle_info(:timeout, %{socket: nil} = state) do
    case :gen_udp.open(0, @socket_opts) do
      {:ok, socket} ->
        {:noreply, %{ state | socket: socket }, @packet_pacer_time}
      _ ->
        {:noreply, state, @socket_retry_time}
    end
  end

  # "handle a timer with a valid socket - attempt to write to it"
  def handle_info(:timeout, %{queue: queue, socket: socket, target: {addr, port}} = state) when (length(queue) > 0) do
    [first | rest] = queue
    case :gen_udp.send(socket, addr, port, first) do
      :ok ->
        {:noreply, %{state | queue: rest}, @packet_pacer_time}
      _ ->
        :gen_udp.close socket
        {:noreply, %{state | socket: nil}, @socket_retry_time}
    end
  end

  def handle_info(:timeout, state) do
    {:noreply, state}
  end

end
