#!/bin/env python3 

import os
import sys
import subprocess
import json
from optparse import OptionParser
parser = OptionParser()
prnchk = 0

subscription = "Crowe Dev 1"
kv_name = "Insight-KeyVault0-Dev1"
secret_name = "InsightAppClientSecret"
user = ''
role = ''
scope = ''
create = ''
stack = {
    "appId": "",
    "displayName": "",
    "name": "",
    "password": "",
    "tenant": ""
    }

parser.add_option("-c", dest="create", help="[-c Yes]. Use this option if creating a Service Principal to use in this script. <Default is No>", type="string")
parser.add_option("-u", dest="user", help="Object/Principal ID of the User, Group or Service Principal being assigned the role. If creating a Service Principal, use this option to designate the Friendly Name. [ex. -u 'MyApp'].", type="string")
parser.add_option("-r", dest="role", help="Name or ID of the Resource Group to check ", type="string")
parser.add_option("-s", dest="scope", help="Name or ID of the Subscription where the Resource Group resides", type="string")

try:
    (options, args) = parser.parse_args()
    if options.role != None:
        role = options.role
    else:
        parser.print_help()
        prnchk + 1
        sys.exit(1)

    if options.scope != None:
        scope = options.scope
    else:
        parser.print_help()
        prnchk + 1
        sys.exit(1)
    if options.user != None:
        user = options.user
    else:
        parser.print_help()
        prnchk + 1
        sys.exit(1)
    if str(options.create).lower() == "yes" or str(options.create).lower() == "y":
        create = options.create
    else:
        create = "No"
except:
    if prnchk > 0:
        parser.print_help()
        sys.exit(1)
    else:
        sys.exit(1)

'''
az role assignment create --assignee c4633b71-d573-415f-82aa-d80ed008d00f --role Contributor --scope /subscriptions/f9ea7f5d-324f-4c97-8b60-6734f9dc6f76/resourceGroups/CroweInsight-Dev1
az ad sp create-for-rbac -n "Insight-QA-Pipeline" --output YAML

'''

def kv_apply():
    print('Placing Client Secret Into Key Vault')
    os.system('az keyvault secret set --name ' + secret_name + ' --vault-name ' + kv_name + ' --value ' + stack["password"] + ' --description "Client Secret for ' + user + '"')
    assign_role()

def create_sp():
    print("Creating Service Principal [" + user + "] under the scope of [" + scope + "]")
    sp_create = subprocess.Popen('az ad sp create-for-rbac -n "' + user + '" --role ' + role + ' --scope ' + scope + ' --output YAML', shell=True, stdout=subprocess.PIPE)
    for spc in sp_create.stdout:
        spc = spc.decode()
        spc = spc.rstrip()
        spc = spc.lstrip()
        if spc.startswith("appId:"):
            spc = spc.strip("appId:").lstrip()
            stack["appID"] = spc
        if spc.startswith("displayName:"):
            spc = spc.strip("displayName:").lstrip()
            stack["displayName"] = spc
        if spc.startswith("password:"):
            spc = spc.strip("password:").lstrip()
            stack["password"] = spc
        if spc.startswith("tenant:"):
            spc = spc.strip("tenant:").lstrip()
            stack["tenant"] = spc
    kv_apply()

def assign_role():
   print("Assigning Role [" + role + "] To [" + user + "] under the scope of [" + scope + "]")
   os.system('az role assignment create --assignee ' + stack["appID"] + ' --role ' + role + ' --scope ' + scope)


print("Switching to Designated Subscription [" + subscription + "]")
os.system('az account set -s "' + subscription + '"')
if create.lower() == "yes" or create.lower() == "y":
    create_sp()
elif create.lower() == "no" or create.lower() == "n":
    assign_role()
else:
    print("Invalid assignment for \"Create\". [" + create + "] is not a valid entry."