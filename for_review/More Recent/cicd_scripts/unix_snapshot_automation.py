#!/usr/local/bin/python3

import sys
import re
import boto3
from time import sleep
import datetime

######################################################################################################################################################
###################################################################### STS INFO ######################################################################
######################################################################################################################################################

roleArn = ''
sts = boto3.client('sts')
accountName = re.findall('.*-(.*)', roleArn)
for aN in accountName:
    aN = aN
roleSessionName = aN + 'AdminRole'
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']



################################################################################################################################################################################
#################################################################### Variable Definitions ######################################################################################
################################################################################################################################################################################
print("Building Variables")
count = 0
countx = 0
localtime = datetime.datetime.now()
locdate = localtime.strftime("%d-%m-%y")
sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
availability_Zone = 'us-east-1a'
AccountInfo = sts.get_caller_identity()
snapshotPrefix = 'DAdamsUnixTest'
sourceInstance = 'i-080cc4282234c0340'
targetInstance = 'i-<<somenumberhere>'
AcctIds = []
KMSKeyId = 'arn:aws:kms:us-east-1::key/eeb5d56a-6110-4f81-9703-'
NPKMSKeyId = 'arn:aws:kms:us-east-1::key/4bca54f1-bf3e-6b14e811ae28'
volumeids = []
snapshotids = []
newvolumeids = []
tags = {
'Key': 'Name',
'Value': 'NetAppAutomationSnapshot0'
}

################################################################################################################################################################################
######################################################################### Discover Volumes In Instance ############################################################
################################################################################################################################################################################

ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
print("Discovering Volumes Within Instance " + sourceInstance)
describe_instances=ec2.describe_instances(InstanceIds=[sourceInstance])
for di in describe_instances['Reservations']:
    dii = di['Instances']
    for volumes in dii[0]['BlockDeviceMappings'][1:]:
        count = count + 1
        volumeid = volumes['Ebs']['VolumeId']
        volumeids.append(volumeid)
        tags.update({'Value': 'NetAppAutomationSnapshot0' + str(count)})
        create_snapshot = ec2.create_snapshot(Description='Automated Snapshot and Volume for Unix NetApp Project', VolumeId=volumeid)
        new_snapshot_id = create_snapshot['SnapshotId']
        snapshotids.append(new_snapshot_id)

print("Snapshots Created. Waiting for [Completed] Status.")

################################################################################################################################################################################
######################################################################### Wait for the Snapshots To Become Available and Create Volumes ##############################################
################################################################################################################################################################################

for sid in snapshotids:
    describe_snapshots = ec2.describe_snapshots(SnapshotIds=[sid])
    for dss in describe_snapshots['Snapshots']:
        state = dss['State']
        while state.lower() != "completed":
            print("Awaiting Snapshot To Complete")
            sleep(10)
            describe_snapshots = ec2.describe_snapshots(SnapshotIds=[new_snapshot_id])
            for dss in describe_snapshots['Snapshots']:
                state = dss['State']
        print("Snapshot Complete. Checking Next Snapshot.")

print("Snapshots Completed. Creating Volume")

################################################################################################################################################################################
######################################################################### Create Volumes From Snapshots ##########################################################
################################################################################################################################################################################

for sid in snapshotids:
    create_volume = ec2.create_volume(AvailabilityZone = availability_Zone, Encrypted=True, SnapshotId=sid)
    newvolumeId = create_volume['VolumeId']
    newvolumeids.append(newvolumeId)

print("Volumes Created. Waiting For [Available] Status.")

################################################################################################################################################################################
######################################################################### Wait for the Volumes To Become Available and Stop Instance ##############################################
################################################################################################################################################################################

for nvid in newvolumeids:
    describe_volumes = ec2.describe_volumes(VolumeIds=[nvid])
    for dvv in describe_volumes['Volumes']:
        volume_state = dvv['State']
        while volume_state.lower() != "available":
            print("Awaiting State to Enter Available.")
            sleep(10)
            describe_volumes = ec2.describe_volumes(VolumeIds=[newvolumeId])
            for dvv in describe_volumes['Volumes']:
                volume_state = dvv['State']

print("Volumes Ready. Stopping Target Instance " + targetInstance)

################################################################################################################################################################################
######################################################################### Stop Instance To Detatch Volumes #######################################################
################################################################################################################################################################################




################################################################################################################################################################################
######################################################################### Cleanup Snapshots ########################################################################
################################################################################################################################################################################

