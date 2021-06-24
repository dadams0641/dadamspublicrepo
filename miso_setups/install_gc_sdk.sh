#!/usr/bin/env bash
set -x

#Ensure user is running as sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ! ${sudo_check} ]] ; then
   echo "This script must be run under sudo, not as root or user." 
   exit 1
fi

echo "Installing Google Cloud SDK"
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
apt install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt update
apt -y install google-cloud-sdk