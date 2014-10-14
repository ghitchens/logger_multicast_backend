LoggerMulticastBackend
======================

A `Logger` backend that uses multicast UDP to deliver log messages. Originally
designed for embedded applications, it allows easily watching the log of a
headless device on the local network.

## Easy Defaults

In your logger config, simply do something like this:

```elixir
config :logger,
backends: [ :console, LoggerMulticastBackend ]
level: :debug,
format: "$time $metadata[$level] $message\n"
```
  
or, at runtime, you can add this to your current config...

```elixir
Logger.add_backend LoggerMulticastBackend
```  

Now, you'll have logging messages sent out on the default target multicast
address, which is 224,0,0,224:9999.   

## Custom Configuration

Don't like the default multicast target? change it by replacing
`LoggerMulticastBackend` in the above examples with something like this:
`{LoggerMulticastBackend, target: {{224,1,22,223}, 4252}}`

The full range of custom configuration options are as follows:

:target - a tuple of the target unicast or multicast address and port, like {{241,0,0,3}, 2}

:level - the level to be logged by this backend. Note that messages are first filtered by the general level configuration in :logger

:format - the format message used to print logs. Defaults to: "$time $metadata[$level] $levelpad$message\n"

:metadata - the metadata to be printed by $metadata. Defaults to an empty list (no metadata)