#!/bin/bash - 
#===============================================================================
#
#          FILE: web.sh
# 
#         USAGE: web/web.sh
# 
#   DESCRIPTION: 66ccff stack, install web-specific components.
# 
#       OPTIONS: ===
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano, bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: long time ago
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error
set -x

SCRATCHVOLUME=$1

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific web for 66ccff"

# Some equired packages for rendering
sudo apt-fast -y install libfontconfig-dev libxrender-dev libxtst6

# install node
curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
sudo apt-get install -y nodejs
curl -L https://npmjs.com/install.sh | sudo sh
sudo npm install -g less

# Install required packages
sudo pip install -r requirements.txt

# 
# Required directories for this app
#

if [[ "${SCRATCHVOLUME}" == "true" ]]; then
    sudo mkdir /media/data/scratch

    sudo ln -s /media/data /data/media 
    sudo ln -s /media/data/scratch /data/scratch

    sudo mkdir -p /data/media/pdfcreator /data/media/reports/pdf
else
    # put everything on the root volume
    sudo mkdir -p /data/media/pdfcreator /data/media/reports/pdf /data/scratch 
fi
sudo chmod 777 -R /media/data/reports
sudo chmod 777 -R /media/data/pdfcreator
sudo chmod 777 -R /media/data/scratch

dcEndLog "install of app-specific web for 66ccff"
