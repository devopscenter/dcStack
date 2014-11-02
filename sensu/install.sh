wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
apt-fast -y install sensu
update-rc.d sensu-client defaults

apt-get install ruby-dev
gem install sensu-plugin
gem install pg
