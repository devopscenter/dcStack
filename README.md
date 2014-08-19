python-stack
============

# Installation

## Clone this repo
    git clone https://github.com/devopscenter/python-stack.git

## Fig is a management service for docker. Install this on the host machine

[Install Fig](http://www.fig.sh/install.html)


## Docker


You can eithr install Docker by installing inside an Ubuntu Virtual Box/Parallels/Virtual Machine or by using boot2docker.

### Ubuntu inside a virtual machine

After you have setup Ubuntu, then [Install the latest Docker](http://docs.docker.com/installation/)

#### Add your username to the docker group.

    sudo gpasswd -a ${USERNAME} docker

#### logout and log back in, then restart docker.

    sudo service docker restart

### Docker Utilities

Install the following utilities. These allow you to enter into a running Docker container.

    docker pull jpetazzo/nsenter
    docker run --rm jpetazzo/nsenter cat /nsenter > /tmp/nsenter
    chmod 755 /tmp/nsenter
    sudo cp /tmp/nsenter /usr/local/bin
    wget https://raw.githubusercontent.com/joshjdevl/docker-tools/master/docker-enter -O docker-enter
    chmod 755 docker-enter
    sudo cp docker-enter /usr/local/bin

### Boot2docker

[Install boot2docker](http://docs.docker.com/installation/mac/)

#### Customization of [boot2docker](https://medium.com/boot2docker-lightweight-linux-for-docker/boot2docker-together-with-virtualbox-guest-additions-da1e3ab2465c)

    curl -L http://static.dockerfiles.io/boot2docker-v1.1.2-virtualbox-guest-additions-v4.3.12.iso > boot2docker.iso
    cp boot2docker.iso ~/.boot2docker/boot2docker.iso

