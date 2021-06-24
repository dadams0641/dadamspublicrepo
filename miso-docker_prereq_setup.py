#!/usr/bin/env python3

import os
import sys
import subprocess

sc = False
print("This Script Requires Sudo. Checking.")
sudo_check = subprocess.Popen('env | grep -i sudo_user', shell=True, stdout=subprocess.PIPE)
for sc in sudo_check.stdout:
    sc = sc.decode()
    sc = sc.rstrip()

if sc:
    print("Successfully Running as Sudo. Continuing.")
else:
    print("Not Running as Sudo. Exiting.")
    sys.exit(1)


os.system("echo $USER")
sys.exit(0)
print("Running SNAP Installer for CMAKE Classic.")
os.system("snap install cmake --classic")

print("Running First APT Installs for GIT, GAWK, and ASCIIDOC-BASE (A2X).")
os.system("apt update; apt install git gawk asciidoc-base -y")
os.system("git clone --recursive https://github.com/reconquest/shdoc; cd shdoc; make install")

print("Setting Up Miso Apt. This may take a while.")
os.mkdir("/miso-apt")
os.system("chown $USER: /miso-apt")
os.system("gcsfuse -o ro,allow_other --implicit-dirs miso-apt /miso-apt")
os.system('echo "deb [trusted=yes] file:/miso-apt/debs/amd64 ./" | tee /etc/apt/sources.list.d/miso-latest.list')
os.system('apt update')
os.system('apt install miso-docker-core miso-docker-help -y')