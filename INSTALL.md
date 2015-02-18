# First time setup

Download and install the [latest VirtualBox platform packages](https://www.virtualbox.org/wiki/Downloads)

Download and install the [latest boot2docker](https://github.com/boot2docker/osx-installer/releases)

After installing boot2docker, [resize the hardrive](boot2docker-init.sh)

Download and install the latest fig
```
sudo pip install --upgrade distribute
sudo pip install -U fig
```

Configure [port forwarding](portforward.sh). Make sure boot2docker-vm is not powered on or started.
```
./portforward.sh
```

Verify port forward rules
```
VBoxManage showvminfo boot2docker-vm | grep "NIC [0-9]* Rule([0-9]*): *name = $1"
```

Add entries to hosts file
```
echo "127.0.0.1 sentry" | sudo tee -a /private/etc/hosts > /dev/null
```
