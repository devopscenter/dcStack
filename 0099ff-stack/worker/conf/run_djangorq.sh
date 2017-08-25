#!/bin/bash

# This script is run by Supervisor to start a single django-rq worker in this process.
# 
# Supports dynamic ENV variables that can be set during each deplay.
# (e.g. can be used to set GIT_SHA, to establish "releases" for Sentry)
#
# The environment variables are specified in dynamics_env.ini, in the [default] section.
# E.g.
#       [default]
#       GIT_SHA=823674826428642838628346
#       OTHER_VALUE=a string
#
# This file does not currently support comments.
# https://stackoverflow.com/a/28794976/8417759

# Start by reading in and setting dynamic environment vars.
source <(grep = /data/deploy/current/dynamic_env.ini)

exec python manage.py rqworker default

