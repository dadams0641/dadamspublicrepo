#!/usr/bin/env python3

import os
import sys
import re
import boto3
import subprocess
import time
import datetime
from termcolor import colored, cprint

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')

roleArnList = ['']


instance_list = [
"i-0cf6c4db3bd0a8e1",
"i-0dabb204d39e94709",
"i-0fe5a69f62b0d8ac3",
"i-0378817f175c612e1",
"i-0009ac70156bcf853",
"i-074b497f886600b77",
"i-0f92f547fe10fc9bb",
"i-053f56444086fa129",
"i-033604bfe7e028a54",
"i-03451dc7064556fc9",
"i-08de37164e4e2c77f",
"i-0c48a53526730ddbc",
"i-0f7735a9ade41bbc9",
"i-0cbaf5ecbb484f6ae",
"i-0870eb914f3d00b33",
"i-07db01e3922c8338f",
"i-0435fd0c6ff8d37ce",
"i-0001f42c3da255491",
"i-0357ddf413b8c047e",
"i-0e3fd63305f473752",
"i-0d35172bc9cb11f28",
"i-0f62c04a675fd95d7",
"i-0af4836b5aae9e48b",
"i-0ae74c6530f35fc08",
"i-04dae22bcc845e079",
"i-0c844806a1216ef3f",
"i-00043781ac02b46c7",
"i-05a24d47666213de2",
"i-0ff57b21b9eb7dbdc",
"i-0a397cb1874ab02fc",
"i-0183843e1ce2ec21d",
"i-0f67c4a4288a7af2b",
"i-0e901e5415161aef8",
"i-05fabf6b61b50c143",
"i-01df24ba7110394c2",
"i-03f31b1ef3663b3be",
"i-06326e368b667c453",
"i-08f3f100e681f8901",
"i-07c6e22bbad35ad3d",
"i-0ae1fb43bfd3c3e9e",
"i-09c68645f8b88242b",
"i-0ca4b96961ca6f464",
"i-0a8350dbc89bb22ec",
"i-0506100dfd23052a1",
"i-0aeb35cb4977c8837",
"i-02d38d9ba383ba4c8",
"i-0efecad3523b2135c",
"i-04612aa06b3570aa8",
"i-0e87851ed81337fd7",
"i-06d2181333a03aa9d"
]

count = 0
for rA in roleArnList:
    roleArn = rA
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
    rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    elb = boto3.client('elbv2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    tsvout = open(aN.upper() + '_Appranix_EC2_Volume_Info.tsv', 'a')
    tsvout.write('HostName\tInstance ID\tInstance Type\tVolume ID\tVolume Mount Point\tVolume Type\tVolume Size\tEncryption\n')
    for il in instance_list:
        describe_instances = ec2.describe_instances(Filters=[{"Name": "instance-id", "Values": [il]}])
        for di in describe_instances['Reservations']:
            for dii in di['Instances']:
                instance_tags = dii['Tags']
                for it in instance_tags:
                    itags = it.values()
                    if "Name" in itags and "AppName" not in itags:
                        itagstr = str(itags)
                        split_itagstr = itagstr.split(',')
                        hostname = split_itagstr[1].strip('[\]\)\']')
                        print(il)
                instance_type = dii['InstanceType']
                volumeinfo = dii['BlockDeviceMappings']
                for vi in volumeinfo:
                    volume_name = vi['DeviceName']
                    volume_id = vi['Ebs']['VolumeId']
                    describe_volumes = ec2.describe_volumes(VolumeIds=[volume_id])
                    for dv in describe_volumes['Volumes']:
                        volume_size = dv['Size']
                        if volume_size > 1024:
                            volume_size = volume_size / 1000
                            volume_size = str(volume_size) + " TB"
                        else:
                            volume_size = str(volume_size) + " GB"
                        volume_type = dv['VolumeType']
                        encryption = dv['Encrypted']
                        encryption = str(encryption)
                        print(hostname + "\t" + il + "\t" + instance_type + "\t" + volume_id + "\t" + volume_name + "\t" + volume_type + "\t" +  volume_size + "\t" + encryption + "\n")
                        tsvout.write(hostname + "\t" + il + "\t" + instance_type + "\t" + volume_id + "\t" + volume_name + "\t" + volume_type + "\t" +  volume_size + "\t" + encryption + "\n")
tsvout.close()