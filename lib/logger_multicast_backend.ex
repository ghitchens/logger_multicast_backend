defmodule LoggerMulticastBackend do

  @moduledoc """
  A `Logger` backend that uses multicast UDP to deliver log messages. Originally
  designed for embedded applications, it allows easily watching the log of a
  headless device on the local network.
  
  # easy peazy
  
  in your logger config, simply do something like this:
  
  ```elixir
  config :logger,
    backends: [ :console, LoggerMulticastBackend ]
    level: :debug,
    format: "$time $metadata[$level] $message\n"
  ```
      
  or, at runtime:
  
  ```elixir
  Logger.add_backend LoggerMulticastBackend
  ```  
  
  LoggerMulticastBackend is configured when specified, and suppors the following options:
  
  :target - a tuple of the target unicast or multicast address and port, like {{241,0,0,3}, 2}
  :level - the level to be logged by this backend. Note that messages are first filtered by the general :level configuration in :logger
  :format - the format message used to print logs. Defaults to: "$time $metadata[$level] $levelpad$message\n"
  :metadata - the metadata to be printed by $metadata. Defaults to an empty list (no metadata)
  """
  
  use GenEvent
  require Logger

  @type level     :: Logger.level
  @type format    :: String.t
  @type metadata  :: [atom]
  
  @socket_opts [:binary, {:broadcast, true}, {:active, false}, {:reuseaddr, true} ]

  @default_format "$time $metadata[$level] $message\n"
  @default_level  :debug
  @default_target {{224,0,0,224}, 9999}
  
  @doc """
  initialize the state of this logger to the environment specified
  in the logger configuration for this backend
  """
  def init({__MODULE__, opts}) do
    Logger.debug "starting multicast backend with #{inspect opts}"
    target = Keyword.get(opts, :target, @default_target)
    state = %{
      target: target,
      socket: nil,
      level: Keyword.get(opts, :level, @default_level),
      format: (Keyword.get(opts, :format, @default_format) |> Logger.Formatter.compile),
      metadata: Keyword.get(opts, :metadata, [])
    }
    {:ok, state}
  end

  def init(__MODULE__) do
    init({__MODULE__, []})
  end

  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, message, timestamp, metadata, state)
    else
      {:ok, state}
    end
  end

  # private helpers

  defp log_event(level, msg, ts, md, %{socket: nil} = state) do
    case :gen_udp.open(0, @socket_opts) do
      {:ok, socket} -> 
        log_event level, msg, ts, md, %{state | socket: socket}
      _ -> 
        {:ok, state}
    end
  end
      
  defp log_event(level, msg, ts, md, %{socket: socket, target: {addr, port}} = state) do
    :ok = :gen_udp.send socket, addr, port, format_event(level, msg, ts, md, state)
    {:ok, state}
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: metadata}) do
    Logger.Formatter.format(format, level, msg, ts, Dict.take(md, metadata))
  end

end
