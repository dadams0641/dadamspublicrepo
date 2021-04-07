#!/usr/bin/env python3

import os
import sys
import re
import subprocess 

wd = False
windir = subprocess.Popen('find ansible/fm_win_ec2_configure/ -name "vars.yml" -type f', shell=True, stdout=subprocess.PIPE)
for wd in windir.stdout:
    wd = wd.decode()
    wd = wd.rstrip()


if wd:
    pass
else:
    print("Using Local Path")
    wd = "group_vars/all/vars.yml"

varfile = open(wd, 'r+')
outfile = open('./outfile', 'w+')
envfile = open('./envfile', 'w+')


for vf in varfile:
    vf = vf.rstrip()
    if "app_name" in vf:
        varname = re.findall(":(.*)", vf)
        statevar = varname[0].replace(' ', '')
    if "environment" in vf:
        envvarname = re.findall(":(.*)", vf)
        envvar = envvarname[0]
        envvar = envvar.lower()
        envvar = envvar.lstrip()
        if envvar == "dev" or envvar == "development":
            env = "dev"
        elif envvar == "prod" or envvar == "production": 
            env = "production"
        outfile.write(statevar)
        envfile.write(env)
outfile.close()
varfile.close()  
envfile.close()