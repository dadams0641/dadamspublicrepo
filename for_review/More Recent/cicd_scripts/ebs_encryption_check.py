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

roleArnList = ['']

'''
roleArnList = []
'''

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
    csvout = open(aN.upper() + '_ebs_encryption_report.csv', 'a')
    csvout.write('Account ID,Volume ID,Attached Instance,Volume State,Volume Type,Volume Size,Encrypted?,Delete on Termination?\n')
    describe_volumes = ec2.describe_volumes()
    for dv in describe_volumes['Volumes']:
        try:
            attached_instance = dv['Attachments'][0]['InstanceId']
            delete_on_termination = dv['Attachments'][0]['DeleteOnTermination']
        except:
            attached_instance = "N/A"
            delete_on_termination = "N/A"
        volume_id = dv['VolumeId']
        volume_state = dv['State']
        volume_type = dv['VolumeType']
        volume_size = dv['Size']
        volume_encryption = dv['Encrypted']
        print(volume_id + " | " + attached_instance + " | " + volume_state  + " | " +  volume_type + " | " + str(volume_size) + " | " + str(volume_encryption) + " | " + str(delete_on_termination))
        csvout.write(AccountID + "-" + aN + "," + volume_id + "," + attached_instance + "," + volume_state + "," + volume_type + "," + str(volume_size) + "," + str(volume_encryption) + "," + str(delete_on_termination) + "\n")