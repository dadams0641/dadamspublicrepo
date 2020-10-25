#!/bin/env python3

import os
import sys
import json
import subprocess

try:
    env = sys.argv[1]
    env = env.lower()
    createdestroy = sys.argv[2]
    createdestroy = createdestroy.lower()
    dbadmin = sys.argv[3]
    kvsecret = sys.argv[4]
except:
    print("No Authentication Info Provided")
    sys.exit(1)
    
try:
    if env == "dev" or env == "prod":
        print("Environment is [" + env +  "]") 
        pass
except:
    print("Environment not properly set. [" + env + "] is not a valid value.")
    sys.exit(1)

json_file = open('./' + env + '.tfvars.json', 'r+')
data = json.load(json_file)
sqloutput = data['json']['sql_mi_db']
tagsoutput = data['json']['tags']
location = data['json']['location']
BU=tagsoutput['BU']
DU=tagsoutput['DU']
Environment=tagsoutput['Environment']
SDU=tagsoutput['SDU']
Product=tagsoutput['Product']
CostCenterCode=tagsoutput['CostCenterCode']
Hierarchy=tagsoutput['Hierarchy']
IndustrySpecialization=tagsoutput['IndustrySpecialization']
ProjectCode=tagsoutput['ProjectCode']
ProjectSponsor=tagsoutput['ProjectSponsor']
TechnicalOwner=tagsoutput['TechnicalOwner']
dbname = sqloutput['db_name']
servername = sqloutput['server_name']
rgname = data['json']['rg_name']
enabled = str(sqloutput['enabled'])
checkmi = 'az sql mi show -g ' + rgname + ' -n ' + servername + ' --query "[name]" --output TSV 2>/dev/null'
subscription_id = subprocess.Popen('az account show --query "[id]" --output TSV', shell=True, stdout=subprocess.PIPE)
for subid in subscription_id.stdout:
    subid = subid.decode()
    subid = subid.rstrip()
    print(subid)

if Environment.lower() == "qa" or Environment.lower() == "dev" or Environment.lower() == "development" or Environment.lower() == "sandbox":
    pubendpoint = "true"
else:
    pubendpoint = "false"

while (True):
    vcheck = False
    vnet_check = subprocess.Popen('az network vnet show -n vnet-' + servername + ' -g ' + rgname + ' --query "[name]" --output TSV', shell=True, stdout=subprocess.PIPE)
    for vcheck in vnet_check.stdout:
        vcheck = vcheck.decode()
        vcheck = vcheck.rstrip()
    if vcheck:
        print("VNET " + vcheck + " found.")
        break

while (True):
    subcheck = False
    print('az network vnet subnet show -n subnet' + servername + ' -g ' + rgname + ' --vnet-name ' + vcheck + ' --query "[name]" --output TSV')
    subnet_check = subprocess.Popen('az network vnet subnet show -n subnet' + servername + ' -g ' + rgname + ' --vnet-name ' + vcheck + ' --query "[name]" --output TSV', shell=True, stdout=subprocess.PIPE)
    for subcheck in subnet_check.stdout:
        subcheck = subcheck.decode()
        subcheck = subcheck.rstrip()
    if subcheck:
        print("Subnet " + str(subcheck) + " found.")
        break

def destroymi():
    os.system('az sql mi delete -n ' + servername + ' -g ' + rgname + ' --yes')
    
def createmi():
    os.system('az sql mi create -g ' + rgname + ' -n ' + servername + ' -l ' + location + ' -i -u ' + dbadmin + ' -p ' + kvsecret + ' --public-data-endpoint-enabled ' + pubendpoint + ' --license-type BasePrice --subnet /subscriptions/' + subid + '/resourceGroups/' + rgname + '/providers/Microsoft.Network/virtualNetworks/vnet-' + servername + '/subnets/subnet' + servername + ' --capacity 8 --storage 32GB --edition GeneralPurpose --family Gen5 --minimal-tls-version 1.2 --no-wait --tags BU="' + BU + '" DU="' + DU + '" Environment="' + Environment + '" SDU="' + SDU + '" Product="' + Product + '" "Cost Center Code"="' + CostCenterCode + '" Hierarchy="' + Hierarchy + '" "Industry Specialization"="' + IndustrySpecialization + '" "Project Code"="' + ProjectCode + '" "Project Sponsor"="' + ProjectSponsor + '" "Technical Owner"="' + TechnicalOwner + '"')

def check():
    micheck = ""
    miccheck = subprocess.Popen(checkmi, shell=True, stdout=subprocess.PIPE)    
    for micheck in miccheck.stdout:
        micheck = micheck.decode()
        micheck = micheck.rstrip()
    if servername in micheck:
        if createdestroy == "apply":
            print("SQL Managed Instance found. Name validated with [" + servername + "]. Exiting with no action.")
            sys.exit(0)
        if createdestroy == "destroy":
            print("SQL Managed Instance found. Name validated with [" + servername + "]. Destroying")
            destroymi()
    else:
        if createdestroy == "apply":
            print("No SQL Managed Instance Found. Creating new instance with name [" + servername + "]")
            createmi()
        if createdestroy == "destroy":
            print("No SQL Managed Instance Found. Exiting with no action.")
            sys.exit(0)

check()
