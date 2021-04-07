#!/bin/env python3
import boto3
import requests

#Assume Functioning Role For Testing and Debugging
roleArn = ''
roleSessionName = 'DAdamsAdmin'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']

ssm = boto3.client('ssm', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
secrets_manager = boto3.client('secretsmanager', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
WaveSSMName = '/wsm/WaveID'
ReplicationActionSSMName = '/wsm/ReplicationAction'
UserSSMName = '/wsm/wsmlogin'
LoginPassSecretName = '/wsm/loginpass'
CETokenSecretName = '/wsm/token'

HOST = 'https://console.cloudendure.com'
headers = {'Content-Type': 'application/json'}
session = {}
endpoint = '/api/latest/{}'
serverendpoint = '/prod/user/servers'
appendpoint = '/prod/user/apps'

WaveID = ssm.get_parameter(Name=WaveSSMName, WithDecryption=False)
replication_action = ssm.get_parameter(Name=ReplicationActionSSMName, WithDecryption=False)
wsm_user = ssm.get_parameter(Name=UserSSMName, WithDecryption=False)

pass_secret = secrets_manager.get_secret_value(SecretId=LoginPassSecretName)
cdToken = secrets_manager.get_secret_value(SecretId=CETokenSecretName)

print(WaveID['Parameter']['Value'])
print(replication_action['Parameter']['Value'])
print(wsm_user['Parameter']['Value'])
print(pass_secret['SecretString'])
print(cdToken['SecretString'])