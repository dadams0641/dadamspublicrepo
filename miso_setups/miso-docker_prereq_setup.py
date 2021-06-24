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

print("Building App Variables from Environment.")
user_grab = subprocess.Popen('echo $SUDO_USER', shell=True, stdout = subprocess.PIPE)
for ug in user_grab.stdout:
    ug = ug.decode()
    ug = ug.rstrip()
    user = ug

try:
    os.mkdir("/root/.ssh")
except:
    pass

os.system("cp -r ~" + user + "/.ssh /root/.")

print("Running SNAP Installer for CMAKE Classic.")
os.system("snap install cmake --classic")

print("Running First APT Installs for GIT, GAWK, and ASCIIDOC-BASE (A2X).")
os.system("apt update; apt install git gawk asciidoc-base make -y")
os.system("echo 'yes' | git clone --recursive https://github.com/reconquest/shdoc; cd shdoc; make install")

print("Finalizing Settings.")
os.system("cd /; echo 'yes' | git clone git@github.com:MisoRobotics/miso-docker.git; chown " + user + ": /miso-docker")
os.system("usermod -aG docker " + user)
print("Setup Complete. If you are running this in a Development Environment you may need to run bootstrap.sh located in the Miso-Docker Repo. \n For your convenience, the Miso-Docker Repo has been cloned to /miso-docker and set to the ownership of " + user + ".")
os.system("rm -f /root/.ssh/*")

