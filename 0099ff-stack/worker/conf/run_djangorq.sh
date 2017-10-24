#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_djangorq.sh
#
#         USAGE: run_djangorq.sh
#
#   DESCRIPTION: This script is run by Supervisor to start a single django-rq 
#                worker in this process.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

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

