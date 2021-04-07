#!/bin/env python

import os
import sys
import re
import boto3
import subprocess
import time

'''
ip = '10.30.59.178'
'''
sgw=boto3.client('storagegateway')
role=''
bucketARN='arn:aws:s3:::res-poc-attach'
location = 'res-poc-attach/dadamsattach'
ip = sys.argv[1]
getkey=subprocess.Popen('./get_key ' + ip, shell=True, stdout=subprocess.PIPE)
for gk in getkey.stdout:
    gk=gk.strip()
print "Storage Gateway Client Key is " + gk + "\n"
gwresponse = sgw.activate_gateway(ActivationKey=gk, GatewayName='dadamsgateway', GatewayTimezone='GMT-5:00', GatewayRegion='us-east-2', GatewayType='FILE_S3', Tags=[{'Key': 'TechnicalOwner','Value': 'David Adams'},])
gwarn=gwresponse['GatewayARN']
print gwarn + "\n"
time.sleep(.5)
print "Creating Gateway and waiting for Running Status"
time.sleep(60)
descinfo=sgw.describe_gateway_information(GatewayARN=gwarn)
state = descinfo['GatewayState']
if state:
    print "The Gateway is " + state
else:
    time.sleep(30)
    print "The Gateway is " + state
gwinfo=sgw.describe_gateway_information(GatewayARN=gwarn)
print gwinfo
diskid=sgw.list_local_disks(GatewayARN=gwarn)
print diskid
dId=diskid['Disks'][0]['DiskId']
print dId
addcache = sgw.add_cache(GatewayARN=gwarn, DiskIds=[dId])
print addcache
stor_nfs=sgw.create_nfs_file_share(ClientToken=gk, GatewayARN=gwarn, Role=role, LocationARN=bucketARN)
print stor_nfs
