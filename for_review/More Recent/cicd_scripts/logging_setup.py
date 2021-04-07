#!/bin/env python3

import subprocess
import boto3
import botocore
import sys


# System Variables


accounts = {
        "POC": "",
        "Dev": "",
        "Prod": "",
        "Workspaces": ""
}
awsregion="us-east-1"
DEFAULT_RESOURCE_TYPE = 'AWS::::Account'
ASSUME_ROLE_MODE = False
a = boto3.client('logs')
b = boto3.client('iam')
c = boto3.client('cloudtrail')
d = boto3.client('transfer')
stsid = boto3.client('sts')
idcheck=stsid.get_caller_identity()
acct=idcheck['Account'] #this is the value of your current account
acct=str(acct) #test by printing this and adding a sys.exit(0) below. Example: print(acct)
accountID= accounts["Prod"]

# User Input Variables
RoleDescription = "Cloudwatch Logging Role for SFTP Instances"
PolicyDescription = "Cloudwatch Logging Policy for SFTP Instances"
GroupName = 'SFTPLogging/FMLoggingGroupProd'
roleName = "SFTPLogging"
policyName = "SFTPLogging"
trailName = "FreedomLogging-Prod"
s3bucketName = "freedommortgage-logging-bucket"
s3keyPrefix = "sftp/trails/"
snsTopicName = "LoggingSNSTopic"
sftpServerName = "<<UniqueIDOfSFTPServer>>"
FMtags = {
        "Name": "Cloud Trail for SFTP",
        "AppOwner": "Mike Burger",
        "Description": "AWS SFTP Transfer Utility for AWS",
        "Environment": "Dev",
        "InstanceManager": "UnixAdmins"
}
assumestatement = '''{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'''
PolicyDocumentRaw= '''{
  "Version": "2012-10-17",
  "Statement": [
    {

      "Sid": "AWSCloudTrailCreateLogStream2014110",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "arn:aws:logs:''' + awsregion + ''':''' + accountID + ''':log-group:''' + GroupName + ''':log-stream:''' + accountID + '''_CloudTrail_''' + awsregion + '''*"
      ]

    },
    {
      "Sid": "AWSCloudTrailPutLogEvents20141101",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:''' + awsregion + ''':''' + accountID + ''':log-group:''' + GroupName + ''':log-stream:''' + accountID + '''_CloudTrail_''' + awsregion + '''*"
      ]
    }
  ]
}'''


# Begin Execution Code

#Create Log Group and Gather Arn
clg = a.create_log_group(logGroupName=GroupName, tags=FMtags)
dlg = a.describe_log_groups(logGroupNamePrefix=GroupName)
grouparn=dlg['logGroups'][0]['arn']

#Create Role and Gather Arn and Role Name
rolecreate = b.create_role(Path='/', RoleName=roleName, AssumeRolePolicyDocument=assumestatement, Description=RoleDescription, tags=FMtags)
rolearn=rolecreate['Role'][0]['Arn']
rolename=rolecreate['Role'][0]['RoleName']

#Create Policy, Gather Policy Arn, and Attach Policy to the role above
policycreate = b.create_policy(PolicyName=policyName, Path='/', PolicyDocument=PolicyDocumentRaw, Description=PolicyDescription)
policyarn=policycreate['Policy'][0]['Arn']
attachpolicy=b.attach_role_policy(RoleName=rolename, PolicyArn=policyarn)

#Create CloudTrail for Logging and attach LogGroup and Role for Logging. 
createtrail = c.create_trail(Name=trailName, S3BucketName=s3bucketName, S3KeyPrefix=s3keyPrefix, IsMultiRegionTrail="true", CloudWatchLogsLogGroupArn=grouparn, CloudWatchLogsRoleArn=rolearn, TagsList=FMtags)
trailarn=createtrail['TrailArn']

#Update SFTP Site with Logging Role
update_sftp=d.update_server(ServerId=sftpServerName, LoggingRole=rolename)

