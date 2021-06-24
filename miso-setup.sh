#!/usr/bin/env bash

set -x

#Ensure NOT Ran as Sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ${sudo_check} ]] ; then
   echo "This script must be ran as user. Not root or sudo." 
   exit 1
fi

SETUPDIR="miso_setups"

sudo $SETUPDIR/install_docker.sh 
sudo $SETUPDIR/install_docker_compose.sh
sudo $SETUPDIR/install_gc_sdk.sh 
sudo $SETUPDIR/install_gcsfuse.sh
$SETUPDIR/miso-apt.sh 
sudo $SETUPDIR/install_miso_docker_and_bash.sh
sudo $SETUPDIR/miso-docker_prereq_setup.py
./miso-gcsfuse-setup.py
