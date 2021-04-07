#!/bin/python

import json
import subprocess
import datetime
from datetime import date
import boto3
import botocore
import sys

instances=[]
tags=[]
t_instances=[]
notTagged=[]
keys=[]
tagKeys=["TechnicalOwner", "LaunchDate", "CattleOrPet"]
y=0
DEFAULT_RESOURCE_TYPE = 'AWS::::Account'
ASSUME_ROLE_MODE = False
a = boto3.client('ec2')
stsid = boto3.client('sts')
idcheck=stsid.get_caller_identity()
acct=idcheck['Account']
acct=str(acct)

check=a.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
x = check['Reservations']
for z in x:
    y = y + 1
    b = x[y-1]['Instances'][0]['InstanceId']
    instances.append(b)

for i in instances:
    tg=a.describe_tags(Filters=[{'Name': 'resource-id', 'Values': [i]}])
    if tg['Tags']:
        print "Instance " + i + " Tag Key is [" + tg['Tags'][0]['Key'] + "]"
        t_instances.append(i)
    else:
        print "Instance " + i + " has no tags to show"
        notTagged.append(i)

def start(event, context):
    ec2NoTags()

def ec2NoTags():
    for nt in notTagged:
        c=a.describe_instances(InstanceIds=[nt])
        dt = c['Reservations'][0]['Instances'][0]['LaunchTime']
        launchdate=dt.date()
        currdate=date.today()
        age=abs((currdate - launchdate).days)
        if age < 14:
            print 'Instance is cattle.'
            catpet="cattle"
        else: 
            print 'Instance is a pet'
            catpet="pet"
        dt = str(dt)
        print "Tagging " + nt + " with LaunchDate" 
        a.create_tags(Resources=[nt], Tags=[{'Key': 'LaunchDate', 'Value': dt}])
        print "Tagging " + nt + " with Cattle or Pet"
        a.create_tags(Resources=[nt], Tags=[{'Key': 'CattleOrPet', 'Value': catpet}])
        print "Tagging " + nt + " with Account ID"
        a.create_tags(Resources=[nt], Tags=[{'Key': 'AccountID', 'Value': acct}])
    ec2SomeTags()

def ec2SomeTags():
    for tagged in t_instances:
        t=a.describe_instances(InstanceIds=[tagged])
        dt = t['Reservations'][0]['Instances'][0]['LaunchTime']
        launchdate=dt.date()
        currdate=date.today()
        age=abs((currdate - launchdate).days)
        if age < 14:
            print 'Instance is cattle.'
            catpet="cattle"
        else: 
            print 'Instance is a pet'
            catpet="pet"
        dt = str(dt)
        print "Checking Tags" 
        y=0
        y=y+1
        tagcheck=a.describe_tags(Filters=[{'Name': 'resource-id', 'Values': [tagged]}])
        tgchk=tagcheck['Tags']
        keychk=tgchk[y-1]['Key']
        valchk=tgchk[y-1]['Value']
        keys.append(keychk)
        if tagKeys[0] not in keys:
            print "No TechnicalOwner Key Defined"
            #a.create_tags(Resources=[nt], Tags=[{'Key': 'TechnicalOwner', 'Value': 'string'}])
        print "Tagging " + tagged + " with LaunchDate" 
        a.create_tags(Resources=[tagged], Tags=[{'Key': 'LaunchDate', 'Value': dt}])
        print "Tagging " + tagged + " with Cattle or Pet"
        a.create_tags(Resources=[tagged], Tags=[{'Key': 'CattleOrPet', 'Value': catpet}])
        print "Tagging " + tagged + " with Account ID"
        a.create_tags(Resources=[tagged], Tags=[{'Key': 'AccountID', 'Value': acct}])


ec2NoTags()
