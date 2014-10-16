## v0.2.0-dev

Major re-architecture

- Now handles port coming/going gracefully
- Caches all data sent when port is not open, and re-sends it when it is
- Keeps up to the last 1024 lines of log for a port that is closed
- Throttles UDP traffic to 10ms packet pacing
- Tolerates IP address changes properly
- Removed blocking send (speeds up logger overall)

## v0.0.1

Initial checkin, lots of bugs