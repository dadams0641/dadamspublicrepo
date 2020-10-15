#!/bin/python3

import os
import sys
import subprocess



role = ''
subscription_list=[]
user_list=[]
roleid = []
namestore = []
count = 0


def check_id():
    for ul in user_list:
        namecheck = subprocess.Popen('az role assignment list --query "[?contains(principalName, \'' + ul + '\')].[id]" --output TSV', shell=True, stdout=subprocess.PIPE) 
        for nc in namecheck.stdout:
            nc = nc.decode()
            nc = nc.rstrip()
            print(ul,nc)
            roleid.append(nc)
    start_strip()
       
def start_strip():
    for rid in roleid:
        pass
'''
    if role == "all":
        print(uid + " will have ALL ROLES stripped from ALL Azure Subscriptions.")
        for sub in subscription_list:
            print("\n" + sub + "\n")
            os.system('az account set -s "' + sub + '"')
            roleid = subprocess.Popen('az role assignment list --all --include-groups --assignee ' + uid + ' --query "[].[id]" --output TSV 2>&1', shell=True, stdout=subprocess.PIPE)
            for rid in roleid.stdout:
                rid = rid.decode()
                rid = rid.rstrip()
                if rid.startswith("ERROR"):
                    print("User Not Found.")
                    other_sub_check()
                else:
                    print('az role assignment delete --ids ' + rid)

    else:
        if role.startswith("/"):
            print(uid + " will have the following role ID stripped. \n " + role)
            for sub in subscription_list:
                print("\n" + sub + "\n")
                os.system('az account set -s "' + sub + '"')
                print('az role assignment delete --ids ' + role)
        else:
            print("Role " + role + " will be removed from user " + namestore[0])
            for sub in subscription_list:
                print("\n" + sub + "\n")
                os.system('az account set -s "' + sub + '"')
                rolepop = subprocess.Popen('az role assignment list --all --include-groups --assignee ' + uid + ' --query "[?roleDefinitionName == \'' + role.title() + '\'].[id]" --output TSV 2>&1', shell=True, stdout=subprocess.PIPE)
                for rp in rolepop.stdout:
                    rp = rp.decode()
                    rp = rp.rstrip()
                    if rp.startswith("ERROR"):
                        print("User Not Found.")
                        other_sub_check()
                    else:
                        print('az role assignment delete --ids ' + rp)
'''

sublist=subprocess.Popen('az account list --query "[].[name]" --output tsv 2>/dev/null', shell=True, stdout=subprocess.PIPE)
for subs in sublist.stdout:
    subs=subs.decode()
    subs=subs.rstrip()
    subscription_list.append(subs)
    if subs.startswith( 'MSDN' ) or  subs.startswith( 'Azure' ) or subs.startswith( 'Pay-As-You-Go' ) or "Visual Studio" in subs or "Trial" in subs or "VS" in subs or "mike" in subs or "Mike" in subs or "Santhosh_1" in subs or "ITA" in subs:
        subscription_list.remove(subs)

for sl in subscription_list:
    print("Assuming Subscription " + sl)
    os.system('az account set -s "' + sl + '"')
    names = subprocess.Popen('az role assignment list --query "[?principalType == \'User\'].[principalName]" --output TSV', shell=True, stdout=subprocess.PIPE)
    for name in names.stdout:
        name = name.decode()
        name = name.rstrip()
        user_list.append(name)
    check_id()