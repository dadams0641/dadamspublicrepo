#!/usr/bin/env python3

import os
import sys
import re
import boto3 
import subprocess
import time
import datetime

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')

try:
    selection = sys.argv[1]
except:
    print("No Selection Given. Exiting.")
    sys.exit(0)


roleArnDict = {}

if selection == 'POC':
    role = roleArnDict['POC']
elif selection == 'Dev':
    role = roleArnDict['Dev']
elif selection == 'Prod':
    role = roleArnDict['Prod']
elif selection == 'Workspaces':
    role = roleArnDict['Workspaces']
else:
    print("Invalid Selection Given. Defaulting to POC.")
    role = roleArnDict['POC']
roleArnList = [role]

count = 0
for rA in roleArnList:
    roleArn = rA
    print("Operating under Role ARN: " + roleArn)
    roleSessionName = 'AdminRole'
    sts = boto3.client('sts')
    assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
    access_key = assumeRole['Credentials']['AccessKeyId']
    secret_key = assumeRole['Credentials']['SecretAccessKey']
    session_token = assumeRole['Credentials']['SessionToken']
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    accountName = re.findall('.*-(.*)', roleArn)
    for aN in accountName:
        aN = aN
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    describe_images = ec2.describe_images(Owners=[AccountID])
    csvout = open(aN + 'OlderThan1Year_ami_report-' + str(currdate) + '.csv', 'a')
    csvout.write('Account ID,Image Name,Image ID,Image Created,Age (In Days)\n')
    for di in describe_images['Images']:
        image_name = di['Name']
        image_id = di['ImageId']
        create_date = di['CreationDate']    
        create_date = re.findall('(\S.*)T', create_date)
        for created in create_date:
            created = str(created)
        image_date_split = created.split('-')
        try:
            image_date = datetime.datetime(year=int(image_date_split[0]), month=int(image_date_split[1]), day=int(image_date_split[2]))
            now_date = datetime.datetime(year=int(currdate_split[0]), month=int(currdate_split[1]), day=int(currdate_split[2]))
            date_delta = now_date - image_date
            days_old = date_delta.days
            if days_old > 364:
                count = count + 1
                days_old = str(days_old)
                print("Deleting " + image_id + " in " + str(AccountID) + " as it is " + days_old + " days old.")
                dereg_image = ec2.deregister_image(ImageId=image_id)
                csvout.write(AccountID + "-" + aN + "," + image_name + "," + image_id + "," + created + "," + days_old + "\n")
        except:
            pass
    csvout.close()
print(count)