#!/bin/bash -e

#
# App-specific web install for 007ACC
#

echo "Begin: install of customer-specific web portion"

sudo pip install -r requirements.txt

curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

sudo apt-get install -y nodejs

sudo apt-get install -y build-essential 

curl -L https://npmjs.com/install.sh | sudo sh

sudo npm install -g less

sudo npm install -g coffee-script

echo "End: install of customer-specific web portion"
