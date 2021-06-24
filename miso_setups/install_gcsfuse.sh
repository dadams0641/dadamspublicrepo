#!/usr/bin/env bash
set -x

#Ensure user is running as sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ! ${sudo_check} ]] ; then
   echo "This script must be run under sudo, not as root or user." 
   exit 1
fi

echo "Installing GCSFuse"
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt update
apt -y install gcsfuse
sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf
