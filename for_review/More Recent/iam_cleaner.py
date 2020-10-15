#!/bin/python3

import os
import sys
import subprocess
import pandas as pd


subscription_list=[]
user_list=[]

try:
    runtype = sys.argv[1]
except:
    runtype = ""
    pass

azrl = "az role assignment list --include-group --include-inherited --all "
qlenid = " --query \"[?principalName=='\"\"'].[principalId, principalType, scope, id]\" --output tsv" 
subscriptions=subprocess.Popen('az account list --query "[].[name]" --output tsv 2>/dev/null', shell=True, stdout=subprocess.PIPE)
for subs in subscriptions.stdout:
    subs=subs.decode()
    subs=subs.rstrip()
    subscription_list.append(subs)
    if subs.startswith( 'MSDN' ) or  subs.startswith( 'Azure' ) or subs.startswith( 'Pay-As-You-Go' ) or "Visual Studio" in subs or "Trial" in subs or "VS" in subs or "mike" in subs or "Mike" in subs or "Santhosh_1" in subs:
        subscription_list.remove(subs)

try:
    os.remove('./tsv_output_temp/Removed_Accounts.tsv')
    print('Removed_Accounts.tsv successfully deleted.')
except:
    pass

tsvout=open('./tsv_output_temp/Removed_Accounts.tsv', 'a')
tsvout.write("Subscription\tID\tType\tScope\n")
for sub in subscription_list:
    print(sub)
    os.system('az account set -s "' + sub + '" 2>/dev/null')
    builduserlist=subprocess.Popen(azrl + '--subscription "' + sub + '"' + qlenid, shell=True, stdout=subprocess.PIPE)
    for bul in builduserlist.stdout:
       bul = bul.decode()
       bul = bul.split()
       bul[1] = bul[1].lower()
       if bul[1] == "serviceprincipal":
           bul[1] = "sp"
       if bul[1] == "user" or bul[1] == "sp":
           checkuser = subprocess.Popen('az ad ' + bul[1] + ' show --id ' + bul[0] + ' --query "[displayName]" --output tsv 2>/dev/null; echo $?', shell=True, stdout=subprocess.PIPE)
       else:
           checkuser = subprocess.Popen('az ad ' + bul[1] + ' show -g ' + bul[0] + ' --query "[displayName]" --output tsv 2>/dev/null; echo $?', shell=True, stdout=subprocess.PIPE) 
       for cu in checkuser.stdout:
           cu = cu.decode()
           cu = cu.rstrip()
           if cu == 0:
               print(cu + " is a valid user and will not be removed")
           else:
               print(bul[0] + " will be removed.")  
               tsvout.write(sub + "\t" + bul[0] + "\t" + bul[1] + "\t" + bul[2] + "\n")
               if runtype == "--dry-run":
                   print('az role assignment delete --ids ' + bul[3])
               else:
                   os.system('az role assignment delete --ids ' + bul[3])
                   print("\t" + bul[0] + " removed.")

tsvout.close()