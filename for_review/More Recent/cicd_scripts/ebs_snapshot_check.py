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
    accountName = re.findall('.*-(.*)', roleArn)
    for aN in accountName:
        aN = aN
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    csvout = open(aN.upper() + '_Deleted_Snapshots-' + str(currdate) + '.csv', 'a')
    csvout.write('Account ID,Snapshot ID,Snapshot Created,Age (In Days),Description\n')
    describe_snapshots = ec2.describe_snapshots(OwnerIds = [AccountID])
    for ds in describe_snapshots['Snapshots']:
        starttime = ds['StartTime']
        starttime = starttime.strftime("%Y-%m-%d")
        snapshotId = ds['SnapshotId']
        description = ds['Description']
        owner = ds['OwnerId']
        starttime_split = starttime.split('-')
        try:
            start_date = datetime.datetime(year=int(starttime_split[0]), month=int(starttime_split[1]), day=int(starttime_split[2]))
            now_date = datetime.datetime(year=int(currdate_split[0]), month=int(currdate_split[1]), day=int(currdate_split[2]))
            date_delta = now_date - start_date
            days_old = date_delta.days
            if days_old > 364:
                count = count + 1
                days_old = str(days_old)
                print("Deleting " + snapshotId + " in " + str(AccountID) + " as it is " + days_old + " days old.")
                delete_snapshot = ec2.delete_snapshot(SnapshotId=snapshotId)
                #print(delete_snapshot)
                csvout.write(AccountID + "-" + aN + "," + snapshotId + "," + str(starttime) + "," + days_old + "," + description + "\n")
        except:
            pass
    csvout.close()
print(count)