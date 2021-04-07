#!/usr/bin/env python3

import os
import sys
import re
import boto3 
import subprocess
import time
import datetime


roleArnList = []

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
    s3 = boto3.client('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    csvout = open(aN + '_s3_bucket_public_access_report.csv', 'a')
    csvout.write('Account ID,Bucket Name,Created\n')
    list_buckets = s3.list_buckets(Owner = AccountID)
    for lb in list_buckets['Buckets']:
        bucket_name = lb['Name']
        create_date = lb['CreationDate']
        create_date = create_date.strftime("%Y-%m-%d")
        try: 
            get_public_access_block = s3.get_public_access_block(Bucket=bucket_name, ExpectedBucketOwner = AccountID)
            if get_public_access_block:
                print(bucket_name + " Blocks Public Access")
        except:
            print(bucket_name + " Allows Public Access. Logging.")
            print(AccountID + "-" + aN + " | " + bucket_name + " | " + str(create_date))
            csvout.write(AccountID + "-" + aN + "," + bucket_name + "," + str(create_date) + "\n")
    csvout.close()
