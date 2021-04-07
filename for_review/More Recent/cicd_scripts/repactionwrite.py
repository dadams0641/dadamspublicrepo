#!/bin/env python3

from __future__ import print_function
import sys
import json
import boto3
import time
from termcolor import colored, cprint
import datetime

localtime = datetime.datetime.now()
loctime = localtime.strftime("%H%M")
resumetime = localtime.replace(hour=16, minute=0, second=0, microsecond=0)
pausetime = localtime.replace(hour=7, minute=0, second=0, microsecond=0)
restime = resumetime.strftime("%H%M")
ptime = pausetime.strftime("%H%M")
ptime = int(ptime)
restime = int(restime)
loctime = int(loctime)

# Code Added by David Adams. Assume Functioning Role For Testing and Debugging. Comment Out When Running as Lambda

roleSessionName = 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']


# Code Added by David Adams. Instantiate Integration with SSM and Secrets Manager
ssm = boto3.client('ssm', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
secrets_manager = boto3.client('secretsmanager', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
WaveSSMName = '/wsm/WaveID'
ReplicationActionSSMName = '/wsm/ReplicationAction'
UserSSMName = '/ce/login'
LoginPassSecretName = '/wsm/loginpass'
CETokenSecretName = '/ce/token'
ceServerList = '/ce/serverList'

# Code Added by David Adams. Autopropagate WaveID and Replication Action from SSM for Lambda
WaveID = ssm.get_parameter(Name=WaveSSMName, WithDecryption=False)
replication_action = ssm.get_parameter(Name=ReplicationActionSSMName, WithDecryption=False)
wsm_user = ssm.get_parameter(Name=UserSSMName, WithDecryption=False)
serverList = ssm.get_parameter(Name=ceServerList, WithDecryption=False)

# Code Added by David Adams. Autopropagate WaveID and Replication Action from Secrets Manager for Lambda
pass_secret = secrets_manager.get_secret_value(SecretId=LoginPassSecretName)
cdToken = secrets_manager.get_secret_value(SecretId=CETokenSecretName)

Waveid = WaveID['Parameter']['Value']
ReplicationAction = replication_action['Parameter']['Value']
CELogin = cdToken['SecretString']
username = wsm_user['Parameter']['Value']
password = pass_secret['SecretString']
customServerList = serverList['Parameter']['Value']
seplist = customServerList.split(',')

print(loctime)
print(ptime)
print(restime)


if  loctime < restime:
    print("Replication Action will be set to Pause")
    ssm.put_parameter(Name=ReplicationActionSSMName, Value="pause", Type="String", Overwrite=True)
elif loctime >= restime:
    print("Replication Action will be set to Start")
    ssm.put_parameter(Name=ReplicationActionSSMName, Value="start", Type="String", Overwrite=True)
else:
    print("Not Understanding What's Going On Here. Something's Wrong!")


newrepssm = ssm.get_parameter(Name=ReplicationActionSSMName, WithDecryption=False)
newrepaction = newrepssm['Parameter']['Value']

print("Replication action was [" + ReplicationAction + "]. This has been updated to [" + newrepaction + "].")
