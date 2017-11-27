#!/usr/bin/env bash
#===============================================================================
#
#          FILE: base-utils.sh
#
#         USAGE: base-utils.sh
#
#   DESCRIPTION: install the base set of utilities for all instances/containers
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
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode
set -o verbose

sudo apt-get -qq update && sudo apt-get -qq -y install python-software-properties software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo add-apt-repository -yu ppa:pi-rho/dev  && \
    sudo apt-get -qq update

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
    sudo apt-get -qq update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install apt-fast

# install the tools for encrypting the filesystem
sudo apt-fast -y install cryptsetup-bin

sudo apt-fast -qq -y install git wget sudo vim unzip curl language-pack-en jq

sudo apt-fast -y install ncdu ntp fail2ban htop

sudo apt-fast -y install tmux-next
sudo mv /usr/bin/tmux-next /usr/bin/tmux

pushd /tmp
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
popd

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | sudo debconf-set-selections
sudo apt-fast -y install unattended-upgrades

#
# Copy logging framework to a known place
#
sudo cp dcEnv.sh /usr/local/bin/dcEnv.sh
sudo chmod 755 /usr/local/bin/dcEnv.sh

#
# Tmux install and config.
#

pushd $HOME
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-pain-control ~/.tmux/plugins/tmux-pain-control
git clone https://github.com/tmux-plugins/tmux-yank ~/.tmux/plugins/tmux-yank
popd

cp tmux.conf $HOME/.tmux.conf
cp bash_profile $HOME/.bash_profile
cp bashrc $HOME/.bashrc
