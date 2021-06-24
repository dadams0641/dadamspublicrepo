#!/usr/bin/env python3

import os
import sys
import subprocess
from time import sleep

sc = False
print("This Script Is Not To Be Ran As Sudo. It Will PROMPT you for a sudo password if required at the end.")
sleep(2)
sudo_check = subprocess.Popen('env | grep -i sudo_user', shell=True, stdout=subprocess.PIPE)
for sc in sudo_check.stdout:
    sc = sc.decode()
    sc = sc.rstrip()

if sc:
    print("Please Do Not Run This As Sudo. Exiting.")
    sys.exit(1)
else:
    print("Not Running As Sudo. Continuing")


print("Setting Up Miso Apt. This may take a while.")
os.system("gcsfuse -o ro,allow_other --implicit-dirs miso-apt /miso-apt")
os.system('echo "deb [trusted=yes] file:/miso-apt/debs/amd64 ./" | tee /etc/apt/sources.list.d/miso-latest.list')
os.system('sudo apt update; sudo apt install miso-docker-core miso-docker-help -y')
