#!/bin/bash - 
#===============================================================================
#
#          FILE: web.sh
# 
#         USAGE: ./web.sh 
# 
#   DESCRIPTION: Executes when at the "building for application stack" phase
#                (ie, as opposed to "building for runtime or application utilities
#                     specific time")
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 10:27:55
#      REVISION:  ---
#===============================================================================

#set -o nounset           # Treat unset variables as an error
set -o errexit            # exit immediately if command exists with a non-zero status
set -x                    # essentially debug mode


#-------------------------------------------------------------------------------
# set up the logging framework
#-------------------------------------------------------------------------------
dcENV_FILE="../../dcEnv.sh"
if [[ -e "${dcENV_FILE}" ]]; then
    source "${dcENV_FILE}"
else
    dcLog(){ echo "${1}"; }
    dcStartLog(){ dcLog "${1}"; }
    dcEndLog(){ dcLog "${1}"; }
fi
#-------------------------------------------------------------------------------
# END setting up the logging framework
#-------------------------------------------------------------------------------


dcStartLog "Starting stack-specific web portion"

dcEndLog "Finished stack-specific web portion"
