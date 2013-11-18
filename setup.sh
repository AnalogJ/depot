#!/bin/bash

###############################################################################
#install Greyhole

sudo sh -c 'echo "deb http://www.greyhole.net/releases/deb stable main" > /etc/apt/sources.list.d/greyhole.list'
curl -s http://www.greyhole.net/releases/deb/greyhole-debsig.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install greyhole

#configure Greyhole
#https://raw.github.com/gboudreau/Greyhole/master/USAGE

###############################################################################
#install Docker

#Ubuntu Raring already comes with the 3.8 kernel, so we don’t need to install it. However, not all systems have AUFS filesystem support enabled, so we need to install it.
sudo apt-get update
sudo apt-get install linux-image-extra-`uname -r`

# Add the Docker repository key to your local keychain
# using apt-key finger you can check the fingerprint matches 36A1 D786 9245 C895 0F96 6E92 D857 6A8B A88D 21E9
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"

# Add the Docker repository to your apt sources list.
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"

# update
sudo apt-get update

# install
sudo apt-get install lxc-docker

# verify that it worked.
sudo docker version

###############################################################################
#setup the env variables for the docker containers

DELUGE_BRIDGE_IP=192.168.1.1
PLEX_BRIDGE_IP=192.168.1.2
SICKBEARD_BRIDGE_IP=192.168.1.3
COUCHPOTATO_BRIDGE_IP=192.168.1.4
MEDIAFRONTPAGE_BRIDGE_IP=192.168.1.5


###############################################################################
#build the docker containers
sudo docker build -rm -t deluge github.com/AnalogJ/docker-deluge

#sudo docker build -rm -t plexx github.com/AnalogJ/docker-plex

sudo docker build -rm -t sickbeard github.com/AnalogJ/docker-sickbeard

#sudo docker build -rm -t couchpotato github.com/AnalogJ/docker-couchpotato

#sudo docker build -rm -t mediafrontpage github.com/AnalogJ/docker-mediafrontpage

###############################################################################
#run the docker containers
# note: the order is important, as some contianers depend on other containers.

DELUGE=$(sudo docker run -p 54323:54323 -d -t deluge)
echo "finished running deluge: $DELUGE"
SICKBEARD=$(sudo docker run -p 54322:54322 -d -t sickbeard)
echo "finished running sickbeard: $SICKBEARD"
###############################################################################
#setup pipework to allow inter-container communication
sudo bash pipework/pipework.sh br1 $DELUGE $DELUGE_BRIDGE_IP/24
echo "bridged deluge"
sudo bash pipework/pipework.sh br2 $SICKBEARD $SICKBEARD_BRIDGE_IP/24

