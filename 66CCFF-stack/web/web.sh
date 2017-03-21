#!/bin/bash -e

#
# App-specific web install for 66CCFF
#

echo "Begin: install of customer-specific web portion"

sudo apt-fast -y install libfontconfig-dev libxrender-dev libxtst6

curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

sudo apt-get install -y nodejs

curl -L https://npmjs.com/install.sh | sudo sh

sudo npm install -g less

sudo pip install -r requirements.txt

sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 

echo "End: install of customer-specific web portion"
