#!/usr/bin/env bash
set -x

#Ensure user is running as sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ! ${sudo_check} ]] ; then
   echo "This script must be run under sudo, not as root or user." 
   exit 1
fi


echo "Installing Docker and Associated Components"
apt update
apt -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt -y install docker-ce docker-ce-cli containerd.io
usermod -aG docker $USER
echo "%docker ALL= /usr/bin/docker" >> /etc/sudoers
