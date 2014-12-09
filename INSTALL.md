# First time setup

Download and install the [latest virtual box](http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-OSX.dmg)

Download and install the [latest boot2docker](https://github.com/boot2docker/osx-installer/releases)

After installing boot2docker, [resize the hardrive](boot2docker-init.sh)

Download and install the latest fig
```
curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > /tmp/fig; chmod 755 /tmp/fig; sudo cp /tmp/fig /usr/local/bin/fig
```

