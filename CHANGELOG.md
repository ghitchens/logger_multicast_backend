## v0.2.2

- fixed configuration API (thanks @fhunleth) and updated README

## v0.2.1

- cleaned up build for elixir 1.4
- hex package improvements

## v0.2.0

Major re-architecture

- Now handles port coming/going gracefully
- Caches all data sent when port is not open, and re-sends it when it is
- Keeps up to the last 1024 lines of log for a port that is closed
- Throttles UDP traffic to 10ms packet pacing
- Tolerates IP address changes properly
- Removed blocking send (speeds up logger overall)

## v0.1.0

- Initial module, lots of bugs
