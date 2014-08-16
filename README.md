python-stack
============

# Installation

## Docker


You can eithr install Docker by installing inside an Ubuntu Virtual Box/Parallels/Virtual Machine or by using boot2docker.
See below for additional instructions for customizing boot2docker to support mounts from the host.
[Install the latest Docker](http://docs.docker.com/installation/)

Add your username for USERNAME. You will also need to logout and login
    sudo gpasswd -a ${USERNAME} docker
    sudo service docker restart


Customization of [boot2docker](https://medium.com/boot2docker-lightweight-linux-for-docker/boot2docker-together-with-virtualbox-guest-additions-da1e3ab2465c)
    curl http://static.dockerfiles.io/boot2docker-v1.1.2-virtualbox-guest-additions-v4.3.12.iso
    cp boot2docker.iso ~/.boot2docker/boot2docker.iso

## Fig

[Install Fig](http://www.fig.sh/install.html)

## Docker Utilities

Install the following utilities. These allow you to enter into a running Docker container.


    docker run --rm jpetazzo/nsenter cat /nsenter > /tmp/nsenter
    chmod 755 /tmp/nsenter
    sudo cp /tmp/nsenter /usr/local/bin
    wget https://raw.githubusercontent.com/joshjdevl/docker-tools/master/docker-enter -O docker-enter
    chmod 755 docker-enter
    sudo cp docker-enter /usr/local/bin

