# LoggerMulticastBackend

[![Hex version](https://img.shields.io/hexpm/v/logger_multicast_backend.svg "Hex version")](https://hex.pm/packages/logger_multicast_backend)

A backend for `Logger` that delivers messages over multicast UDP.

Designed for headless embedded applications, it allows watching the log over the local network.

## Usage

The package can be installed by adding `logger_multicast_backend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:logger_multicast_backend, "~> 0.2"}]
end
```

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

To capture log messages on systems with [socat](http://www.dest-unreach.org/socat/), run:

```
$ socat - udp-recv:9999,ip-add-membership=224.0.0.224:eth0
```

or use [cell](https://github.com/nerves-project/cell-tool):

```
$ cell watch
```

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
