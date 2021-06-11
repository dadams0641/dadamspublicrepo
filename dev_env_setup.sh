#!/bin/env bash


#Ensure user is running as sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ! ${sudo_check} ]] ; then
   echo "This script must be run under sudo, not as root or user." 
   exit 1
fi


echo "Installing Docker and Associated Components"
apt-get update
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
usermod -aG docker $USER

echo "Installing Google Cloud SDK"
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update
apt-get -y install google-cloud-sdk


echo "Installing GCSFuse"
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update
apt-get -y install gcsfuse

gcloud auth login
gcloud auth application-default login


echo "Adding Miso-Apt Repo"
mkdir /miso-apt
chown $USER:$USER /miso-apt
gcsfuse -o ro,allow_other --implicit-dirs miso-apt /miso-apt
echo "deb [trusted=yes] file:/miso-apt/debs/amd64 ./" | tee /etc/apt/sources.list.d/miso-latest.list

echo "Adding Miso-Docker and Miso-Bash"
apt-get update
apt-get -y install miso-docker-* miso-bash-*

echo "Installing Docker Compose"
curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

