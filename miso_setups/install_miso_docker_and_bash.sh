#!/usr/bin/env bash
set -x

#Ensure user is running as sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ! ${sudo_check} ]] ; then
   echo "This script must be run under sudo, not as root or user." 
   exit 1
fi


echo "Installing Miso-Docker and Miso-Bash"
apt update
apt -y install miso-docker-* miso-bash-*