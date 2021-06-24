#!/usr/bin/env bash

set -x

#Ensure NOT Ran as Sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ${sudo_check} ]] ; then
   echo "This script must be ran as user. Not root or sudo." 
   exit 1
fi

echo "Adding Miso-Apt Repo"
sudo mkdir /miso-apt
sudo chown $USER:$USER /miso-apt
gcsfuse -o ro,allow_other --implicit-dirs miso-apt /miso-apt
echo "deb [trusted=yes] file:/miso-apt/debs/amd64 ./" | sudo tee /etc/apt/sources.list.d/miso-latest.list
