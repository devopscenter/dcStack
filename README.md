python-stack
============

# Installation

## Docker

[Install the latest Docker](http://docs.docker.com/installation/)

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

