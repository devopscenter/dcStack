#!/bin/bash -e

echo $PWD
sudo pip install -r requirements.txt
pushd /installs

curl -sL https://deb.nodesource.com/setup | sudo bash -

sudo apt-get install -y nodejs

curl -L https://npmjs.com/install.sh | sudo sh

sudo npm install -g less

sudo npm install -g coffee-script

popd

echo "Installed customer-specific web and worker portion"
