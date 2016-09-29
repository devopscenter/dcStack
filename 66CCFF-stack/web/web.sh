#!/bin/bash -e

sudo apt-fast -y install libfontconfig-dev libxrender-dev libxtst6

curl -sL https://deb.nodesource.com/setup_6.x | sudo bash -

sudo apt-get install -y nodejs

curl -L https://npmjs.com/install.sh | sudo sh

sudo npm install -g less

sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 

