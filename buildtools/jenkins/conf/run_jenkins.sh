#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_jenkins.sh
#
#         USAGE: run_jenkins.sh
#
#   DESCRIPTION: 
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
# Copyright 2014-2018 devops.center llc
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


# Note that this assumes that a certificate and its private key (in rsa format) have been placed in certs/jenkins.crt and certs/jenkins.pem, off the jenkins home directory.

. /etc/default/jenkins && export JENKINS_HOME && export AWS_KEYS && \
    exec /usr/bin/java -Djava.awt.headless=true -jar /usr/share/jenkins/jenkins.war --webroot=/var/cache/jenkins/war \
    --httpPort=-1 --ajp13Port=-1 --httpsPort=4443 --httpsCertificate=${JENKINS_HOME}/certs/jenkins.crt --httpsPrivateKey=${JENKINS_HOME}/certs/jenkins.pem
