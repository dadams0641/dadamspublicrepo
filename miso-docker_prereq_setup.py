#!/usr/bin/env python3

import os
import sys
import subprocess

sudo_check = False
print("This Script Requires Sudo. Checking.")
sudo_check = subprocess.Popen('env | grep -i sudo_user', shell=True, stdout=subprocess.PIPE)
if sudo_check:
    for sc in sudo_check.stdout:
        sc = sc.decode()
        sc = sc.rstrip()
        print("Successfully Running as Sudo. Continuing")
else:
    print("Not Running as Sudo. Exiting.")
    sys.exit(1)

