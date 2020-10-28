#!/bin/env python3

import os
import sys
import json
import subprocess

update = sys.argv[1]

json_file = open('../terraform.tfvars.json', 'r+')
webout = open('webapp_output', 'w+')
data = json.load(json_file)
application = data['json']['application']
environment = data['json']['environment_name']
location = data['json']['location']
myasp = application + "-" + environment + "-AppServicePlan"
rgname = application + '-' + environment + data['json']['iteration']
webapp = application + "-" + environment + "-webapp"
slotname = "blue"


if update.lower() == "no":
    create_webapp = subprocess.Popen('az webapp create -g ' + rgname + ' -p ' + myasp + ' -n ' + webapp + ' -r "PHP|7.4" -l', shell=True, stdout=subprocess.PIPE)
    for cw in create_webapp.stdout:
        cw = cw.decode()
        print(cw)
        webout.write(cw)
    create_slot = subprocess.Popen('az webapp deployment slot create -n' + webapp + ' -g ' + rgname + ' -s ' + slotname)
    for cs in create_slot.stdout:
        cs = cs.decode()
        print(cs)
    print("Deploying Website")
    os.system("git clone 'https://tt-deploy-user:4zuR3d3pl0y!@" + webapp + ".scm.azurewebsites.net:443/teletrack-sandbox-webapp.git'; cd teletrack-sandbox-webapp; cp -r ../test_site/* .; git add -A; git commit -m 'updating code via pipeline'; git push origin master")
    os.system("rm -rf teletrack-sandbox-webapp")
elif update.lower() == "yes":
    os.system("git clone 'https://tt-deploy-user:4zuR3d3pl0y!@" + webapp + ".scm.azurewebsites.net:443/teletrack-sandbox-webapp.git'; cd teletrack-sandbox-webapp; cp -r ../test_site/* .; git add -A; git commit -m 'updating code via pipeline'; git push origin master")
    os.system("rm -rf teletrack-sandbox-webapp")
else:
    print("No Valid Update Command Given")
    sys.exit(1)
