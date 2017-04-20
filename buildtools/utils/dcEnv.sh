#!/bin/bash - 
#===============================================================================
#
#          FILE: dcEnv.sh
# 
#         USAGE: ./dcEnv.sh 
# 
#   DESCRIPTION: script to include in other scripts that set up the environment
#                and provides some basic utility functions
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 12:02:46
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

dcLog()
{
    msg=$1
    state=$2

    scriptName=$(basename -- "$0")
    TIMESTAMP=$(date +%F_%T)

    if [[ ! -z ${state} ]]; then
        echo "[${TIMESTAMP}]:${scriptName}:${state}:${msg}"
    else
        echo "[${TIMESTAMP}]:${scriptName}::${msg}"
    fi
}

dcStartLog()
{
    msg=$1
    dcLog "${msg}" "START"
}

dcEndLog()
{
    msg=$1
    dcLog "${msg}" "END"
}

