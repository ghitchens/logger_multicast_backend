# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  backends: [ :console, LoggerMulticastBackend ]

config :logger, :logger_multicast_backend,
  format: "$node $metadata[$level] $message\n"
  #target: {{224,0,0,224}, 9999}
