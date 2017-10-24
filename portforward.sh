#!/usr/bin/env bash
#===============================================================================
#
#          FILE: drop-index.sh
#
#         USAGE: ./drop-index.sh
#
#   DESCRIPTION: Docker Stack - Docker stack to manage infrastructures
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

VBoxManage modifyvm "default" --natpf1 "tcp-port80,tcp,,80,,80" || true
VBoxManage modifyvm "default" --natpf1 "udp-port80,udp,,80,,80" || true
VBoxManage modifyvm "default" --natpf1 "tcp-port8000,tcp,,8000,,8000" || true
VBoxManage modifyvm "default" --natpf1 "udp-port8000,udp,,8000,,8000" || true
VBoxManage modifyvm "default" --natpf1 "tcp-port8080,tcp,,8080,,8080" || true
VBoxManage modifyvm "default" --natpf1 "udp-port8080,udp,,8080,,8080" || true
VBoxManage modifyvm "default" --natpf1 "tcp-port9000,tcp,,9000,,9000" || true
VBoxManage modifyvm "default" --natpf1 "udp-port9000,udp,,9000,,9000" || true
VBoxManage modifyvm "default" --natpf1 "tcp-port4433,tcp,,4433,,4433" || true
VBoxManage modifyvm "default" --natpf1 "udp-port4433,udp,,4433,,4433" || true
VBoxManage modifyvm "default" --natpf1 "tcp-port9999,tcp,,9999,,9999" || true
VBoxManage modifyvm "default" --natpf1 "udp-port9999,udp,,9999,,9999" || true
VBoxManage modifyvm "default" --natpf1 "tcp-port5555,tcp,,5555,,5555" || true
VBoxManage modifyvm "default" --natpf1 "udp-port5555,udp,,5555,,5555" || true
