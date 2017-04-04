defmodule LoggerMulticastBackend do

  @moduledoc """
  A backend for `Logger` that delivers messages over multicast UDP.

  Designed for headless embedded applications, it allows watching the log over the local network.

  ## Easy Defaults

  In your logger config, simply do something like this:

  ```elixir
  config :logger,
          backends: [ :console, LoggerMulticastBackend ]
  ```

  or, at runtime, you can add this to your current config...

  ```elixir
  Logger.add_backend LoggerMulticastBackend
  ```

  Now, you'll have logging messages sent out on the default target multicast address, which is 224.0.0.224:9999.

  ## Custom Configuration

Don't like the default multicast target or format? Change it by including options like this:

  ```elixir
  config :logger, :logger_multicast_backend,
      target: {{224,1,22,223}, 4252},
      format: "$time $metadata[$level] $message\\n",
      level:  :info
  ```

  The full range of custom configuration options in the tuple are as follows:

  - __target__ - a tuple of the target unicast or multicast address and port, like {{241,0,0,3}, 52209}

  - __level__ - the level to be logged by this backend. Note that messages are first filtered by the general level configuration in :logger

  - __format__ - the format message used to print logs.
  Defaults to: ``"$time $metadata[$level] $levelpad$message\n"``

  - __metadata__ - the metadata to be printed by $metadata.
  Defaults to an empty list (no metadata)

  """

  use GenEvent
  require Logger

  # @type level     :: Logger.level
  # @type format    :: String.t
  # @type metadata  :: [atom]

  @default_target {{224,0,0,224}, 9999}
  @default_format "$time $metadata[$level] $message\n"

  @doc false
  def init({__MODULE__, opts}) when is_list(opts) do
    env = Application.get_env(:logger, :logger_multicast_backend, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, :logger_multicast_backend, opts)

    level  = Keyword.get(opts, :level)
    metadata = Keyword.get(opts, :metadata, [])
    format_opts = Keyword.get(opts, :format, @default_format)
    format = Logger.Formatter.compile(format_opts)
    target = Keyword.get(opts, :target, @default_target)

    Logger.debug "starting multicast backend on target #{inspect target}"
    {:ok, sender} = GenServer.start_link(LoggerMulticastSender, target)

    state = %{sender: sender, level: level, format: format, metadata: metadata}
    {:ok, state}
  end

  def init(__MODULE__), do: init({__MODULE__, []})

  @doc false
  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      entry = format_event(level, message, timestamp, metadata, state)
      :ok = GenServer.cast(state.sender, {:add_entry, entry})
    end
    {:ok, state}
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: metadata}) do
    Logger.Formatter.format(format, level, msg, ts, Keyword.take(md, metadata))
  end

end
