#!/bin/bash -e
cp wheelhouse /wheelhouse
cp requirements.txt /installs/requirements.txt
cp web.sh /installs/web.sh

sudo apt-fast -y install libfontconfig-dev libxrender-dev libxtst6

curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

sudo apt-get install -y nodejs

curl -L https://npmjs.com/install.sh | sudo sh

sudo npm install -g less

sudo mkdir -p /data/deploy /data/media /data/media/pdfcreator /data/media/reports/pdf /data/scratch 

echo "Installed customer-specific web portion"
