python-stack
============

# Installation

## Clone this repo
    git clone https://github.com/devopscenter/python-stack.git

## Docker

[Install the latest Docker](http://docs.docker.com/installation/)

## Add your username to the docker group.

    sudo gpasswd -a ${USERNAME} docker

## logout and log back in, then restart docker.

    sudo service docker restart

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

