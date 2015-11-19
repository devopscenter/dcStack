#!/bin/bash

# note that this is only run on an instance, not within a container.

sudo pip install supervisor-logging

export SYSLOG_SERVER=logs2.papertrailapp.com
export SYSLOG_PORT=48809
export SYSLOG_PROTO=tcp
