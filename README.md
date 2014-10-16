LoggerMulticastBackend
======================

An Elixir `Logger` backend that uses multicast UDP to deliver log messages.
Designed for headless embedded applications, it allows watching the
log over the local network.

## Easy Defaults

In your logger config, simply do something like this:

```elixir
config :logger,
        backends: [ :console, LoggerMulticastBackend ],
        level: :debug,
        format: "$time $metadata[$level] $message\n"
```
  
or, at runtime, you can add this to your current config...

```elixir
Logger.add_backend LoggerMulticastBackend
```  

Now, you'll have logging messages sent out on the default target multicast
address, which is 224,0,0,224:9999.   

## Custom Target Configuration

Don't like the default multicast target or format? change it by replacing
`LoggerMulticastBackend` in the above examples with a tuple including options something like this:

```elixir
config :logger, backends: [ 
                    :console, 
                    {LoggerMulticastBackend, 
                        target: {{224,1,22,223}, 4252},
                        level:  :info}
                ]
```

The full range of custom configuration options in the tuple are as follows:

:target - a tuple of the target unicast or multicast address and port, like {{241,0,0,3}, 2}

:level - the level to be logged by this backend. Note that messages are first filtered by the general level configuration in :logger

:format - the format message used to print logs. Defaults to: "$time $metadata[$level] $levelpad$message\n"

:metadata - the metadata to be printed by $metadata. Defaults to an empty list (no metadata)
