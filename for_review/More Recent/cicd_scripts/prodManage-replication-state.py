#!/bin/env python3


from __future__ import print_function
import sys
import argparse
import requests
import json
import boto3
import getpass
import time
from termcolor import colored, cprint


# Code Added by David Adams. Assume Functioning Role For Testing and Debugging. Comment Out When Running as Lambda
roleArn = ''
roleSessionName = 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']

HOST = 'https://console.cloudendure.com/'
headers = {'Content-Type': 'application/json'}
session = {}
endpoint = 'api/latest/{}'
projectendpoint = 'projects'
serverendpoint = 'prod/user/servers'
appendpoint = 'prod/user/apps'

# Code Added by David Adams. Instantiate Integration with SSM and Secrets Manager
ssm = boto3.client('ssm', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
secrets_manager = boto3.client('secretsmanager', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
WaveSSMName = '/wsm/WaveID'
ReplicationActionSSMName = '/wsm/ReplicationAction'
UserSSMName = '/ce/login'
LoginPassSecretName = '/wsm/loginpass'
CETokenSecretName = '/ce/token'
ceServerList = '/ce/serverList'
proj_id = []
ServerList = []
machineData = []
ServerNames = []
MachineStatus = []
IDStatus = {}
ServerID = {}
customdict = {}

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

'''

Uncomment this section to test parameters in debugging. 

print(Waveid)
print(ReplicationAction)
print(CELogin)
print(username)
print(password)


'''

def CElogin(CELogin, endpoint):
    login_data = {'userApiToken': CELogin}
    r = requests.post(HOST + endpoint.format('login'),
                  data=json.dumps(login_data), headers=headers)
    print(r)
    if r.status_code == 200:
        print("CloudEndure : You have successfully logged in")
        print("")
    if r.status_code != 200 and r.status_code != 307:
        if r.status_code == 401 or r.status_code == 403:
            print('ERROR: The CloudEndure login credentials provided cannot be authenticated....')
        elif r.status_code == 402:
            print('ERROR: There is no active license configured for this CloudEndure account....')
        elif r.status_code == 429:
            print('ERROR: CloudEndure Authentication failure limit has been reached. The service will become available for additional requests after a timeout....')
    
    # check if need to use a different API entry point
    if r.history:
        endpoint = '/' + '/'.join(r.url.split('/')[3:-1]) + '/{}'
        r = requests.post(HOST + endpoint.format('login'),
                      data=json.dumps(login_data), headers=headers)
                      
    session['session'] = r.cookies['session']
    try:
       headers['X-XSRF-TOKEN'] = r.cookies['XSRF-TOKEN']
    except:
       pass

def GetCEProject():
    print('Building Project List')
    r = requests.get(HOST + endpoint.format('projects'), headers=headers, cookies=session)
    project = r.json()
    items = project['items']
    if not items:
        print("ERROR: No Projects in List")
    for it in items:
        print("Adding Project ID " + it['id'] + " To Project List")
        proj_id.append(it['id'])
    if r.status_code != 200:
        print("ERROR: Failed to fetch the project....")
        sys.exit(2)
    if not proj_id:
        print("ERROR: Failed to retain Project IDs")
        sys.exit(3)

def GetServerList():
    servercount = 0
    for pjl in proj_id:
        print("Getting Server List for Project with the ID " + pjl)
        machine_endpoint = "projects/" + pjl + "/machines"
        r = requests.get(HOST + endpoint.format(machine_endpoint), headers=headers, cookies=session)
        machine_dump = r.json()
        machineData.append(machine_dump['items'])
        for mach_data in machineData:
            for md in mach_data:
                machine_ids = md['id']
                machine_names = md['sourceProperties']['name'].lower()
                machine_status = md['replicationStatus']
                IDStatus[machine_ids] = machine_status
                ServerID[machine_names] = machine_ids
                print(machine_names + " with the Machine ID " + machine_ids + " found and stored. Machine is Currently " + machine_status)
                ServerList.append(machine_ids)
                ServerNames.append(machine_names)
                MachineStatus.append(machine_status)
                servercount = servercount + 1
        print('\nProject with the ID ' + pjl + ' has ' + str(servercount) + ' servers.\n')

def Replication_Action():
        for pjl in proj_id:
            print("Working on Project " + pjl)
            for sepl in seplist:
                if sepl in ServerID:
                    sid = ServerID[sepl]
                    stus = IDStatus[sid]
                    print('Grabbing information for machine with the name ' + sepl + ' and ID ' + sid)
                    print("Proceding With Replication Action " + ReplicationAction)
                    machine_data = {'machineIDs': [sid]}
                    if ReplicationAction.lower() == "check":
                        print("Machine Status is " + stus) 
                    if ReplicationAction.lower() == "start":
                        r = requests.post(HOST + endpoint.format('projects/{}/startReplication').format(pjl), headers=headers,  cookies=session, data=json.dumps(machine_data))
                        print(r)
                        print(r.json())
                        if "200" in str(r):
                           print("Replication started for machine..  " + sepl)
                        else:
                            print("Replication could not be started for machine..  " + sepl)
                            pass
                    if ReplicationAction.lower() == "pause":
                        r = requests.post(HOST + endpoint.format('projects/{}/pauseReplication').format(pjl), headers=headers, cookies=session, data=json.dumps(machine_data))
                        if "200" in str(r):
                            print("Replication paused for machine..  " + sepl)
                        else:
                            print("Replication could not be paused for machine..  " + sepl)
                    if ReplicationAction.lower() == "stop":
                        '''
                        print("Stopping the Replication is NOT advised at this time. Please reach out to Ahmad Nafiseh (ahmad.nafiseh@freedommortgage.com) to have this action performed")
                        sys.exit(0)
                        '''
                        r = requests.post(HOST + endpoint.format('projects/{}/stopReplication').format(pjl), headers=headers, cookies=session, data=json.dumps(machine_data))
                        if "200" in str(r):
                            print("Replication stopped for machine..  " + sepl)
                        else:
                            print("Replication could not be stopped for machine..  " + sepl)

def main(arguments):
    print("")
    print("************************")
    print("* Login to CloudEndure *")
    print("************************")
    cprint("\nCAUTION! The Selected Replication Action is " + ReplicationAction.upper(), 'red', attrs=['blink'])
    time.sleep(5)
    r = CElogin(CELogin, endpoint)
    if r is not None and "ERROR" in r:
        print(r)
    GetCEProject() 
    GetServerList() 
    Replication_Action()
    '''
    print("*****************************")
    print("*  " + str(ReplicationAction.upper())+ "  Replication *")
    print("*****************************")
    replication_action(Projects, token, ReplicationAction)
    print("")
    print("*****************************")
    print("* Verify replication status *")
    print("*****************************")
    verify_replication(Projects, token)
    '''

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
