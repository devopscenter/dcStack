#!/usr/bin/env bash
#===============================================================================
#
#          FILE: install-supervisor.sh
#
#         USAGE: install-supervisor.sh
#
#   DESCRIPTION: Install supervisor 3.2.3 via pip install, and mimic installation 
#                structure and configs of apt-get install. Must be run after python
#                and it's pip is installed.
#
#                There is a single argument: "custom" if python will install supervisor
#                in /usr/local/opt/python/bin/, "normal" (or anything else if python 
#                will install supervisor in /usr/local/bin.
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

sudo pip install supervisor
if [[ $1 == "custom" ]]; then
  export PATH="${1}/:${PATH}"
  sudo cp initd-supervisor-custom /etc/init.d/supervisor
else
  sudo cp initd-supervisor /etc/init.d/supervisor
fi

# Create the config directory structure that the ubuntu-packaged supervisor uses.
sudo mkdir /etc/supervisor
sudo mkdir /etc/supervisor/conf.d
sudo mkdir /var/log/supervisor
sudo cp supervisord.conf /etc/supervisor/

# Install the supervisor logging plug-in
# https://github.com/Supervisor/supervisor/issues/446
sudo pip install supervisor-logging

# if present, remvoe spurious rsyslogd config file (so that it does not run under supervisor!)
if [[ -f /etc/supervisor/conf.d/rsyslogd.conf ]]; then
    sudo rm /etc/supervisor/conf.d/rsyslogd.conf
fi

# make a symlink so that the pip-installed supervisor can find the configuration file
sudo ln -s /etc/supervisor/supervisord.conf /etc/supervisord.conf

# Now make sure that it starts up upon reboot
sudo update-rc.d supervisor defaults

# Finally set up symlinks if installed in the custom location (using a non-ubuntu python)
if [[ $1 == "custom" ]]; then
  sudo ln -s /usr/local/opt/python/bin/supervisord /usr/bin/supervisord
  sudo ln -s /usr/local/opt/python/bin/supervisorctl /usr/bin/supervisorctl
fi
