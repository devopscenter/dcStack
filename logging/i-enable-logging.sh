#!/bin/bash

# note that this is only run on an instance, not within a container.
# also, must be run after supervisor is installed.

# Enable logging to papertrail through rsyslogd, using TLS and queueing
./papertrail.sh

# Set the papertrail destination in rsyslogd and supervisor.
./set-destination.sh

