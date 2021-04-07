# Copyright 2008-2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.

# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at
# http://aws.amazon.com/apache2.0/
# or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

from __future__ import print_function
import sys
import argparse
import requests
import json
import boto3
import getpass
import time



# Code Added by David Adams. Assume Functioning Role For Testing and Debugging. Comment Out When Running as Lambda
roleArn = ''
roleSessionName = 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']

HOST = 'https://console.cloudendure.com/api/latest/'
headers = {'Content-Type': 'application/json'}
session = {}
endpoint = '/api/latest/'
#machineendpoint = 'projects/' + projectId + '/machines'
projectendpoint = 'projects'
serverendpoint = '/prod/user/servers'
appendpoint = '/prod/user/apps'

# Code Added by David Adams. Instantiate Integration with SSM and Secrets Manager
ssm = boto3.client('ssm', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
secrets_manager = boto3.client('secretsmanager', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
WaveSSMName = '/wsm/WaveID'
ReplicationActionSSMName = '/wsm/ReplicationAction'
UserSSMName = '/ce/login'
LoginPassSecretName = '/wsm/loginpass'
CETokenSecretName = '/ce/token'

# Code Added by David Adams. Autopropagate WaveID and Replication Action from SSM for Lambda
WaveID = ssm.get_parameter(Name=WaveSSMName, WithDecryption=False)
replication_action = ssm.get_parameter(Name=ReplicationActionSSMName, WithDecryption=False)
wsm_user = ssm.get_parameter(Name=UserSSMName, WithDecryption=False)

# Code Added by David Adams. Autopropagate WaveID and Replication Action from Secrets Manager for Lambda
pass_secret = secrets_manager.get_secret_value(SecretId=LoginPassSecretName)
cdToken = secrets_manager.get_secret_value(SecretId=CETokenSecretName)

#Refactored URL Definitions
LoginHOST = "https://1ue1znd9lg.execute-api.us-east-1.amazonaws.com"
UserHOST = "https://gsmo15w6zl.execute-api.us-east-1.amazonaws.com"
userapitoken = '''{
"userApiToken": CELogin
}'''

Waveid = WaveID['Parameter']['Value']
ReplicationAction = replication_action['Parameter']['Value']
CELogin = cdToken['SecretString']
username = wsm_user['Parameter']['Value']
password = pass_secret['SecretString']

#print(CELogin)
#logince = requests.post(HOST + "login", headers=headers, data = json.dumps({"userApiToken": CELogin}))
#readtoken = logince.json()
#print(readtoken)
#print(readtoken['apiToken'])
#getprojects = requests.get(HOST + "projects")
#print(HOST + "projects")
#print(getprojects)



#####################################################################################



def CElogin(userapitoken, endpoint):
    login_data = {'userApiToken': userapitoken}
    r = requests.post(HOST + endpoint.format('login'),
                  data=json.dumps(login_data), headers=headers)
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

def GetCEProject(projectname):
    r = requests.get(HOST + endpoint.format('projects'), headers=headers, cookies=session)
    if r.status_code != 200:
        print("ERROR: Failed to fetch the project....")
        sys.exit(2)
    try:
        # Get Project ID
        project_id = ""
        projects = json.loads(r.text)["items"]
        project_exist = False
        for project in projects:
            if project["name"] == projectname:
               project_id = project["id"]
               project_exist = True
        if project_exist == False:
            print("ERROR: Project Name does not exist in CloudEndure....")
            sys.exit(3)
        return project_id
    except:
        print("ERROR: Failed to fetch the project....")
        sys.exit(4)

def ProjectList(userapitoken, HOST, endpoint, projectendpoint):
# Get all Apps and servers from migration factory
    auth = {"userApiToken": userapitoken}
    print(auth)
    #servers = json.loads(requests.get(HOST + endpoint.format(projectendpoint), headers=auth).text)
    servers = requests.get(HOST + endpoint.format(projectendpoint), headers=auth)
    print(HOST + endpoint.format(projectendpoint))
    print(servers)
    sys.exit(0)
    apps = json.loads(requests.get(HOST + appendpoint, headers=auth).text)
    #print(apps)
    newapps = []
    
    CEProjects = []
    # Check project names in CloudEndure
    for app in apps:
        Project = {}
        if 'wave_id' in app:
            if str(app['wave_id']) == str(Waveid):
                newapps.append(app)
                if 'cloudendure_projectname' in app:
                    Project['ProjectName'] = app['cloudendure_projectname']
                    project_id = GetCEProject(Project['ProjectName'])
                    Project['ProjectId'] = project_id
                    if Project not in CEProjects:
                        CEProjects.append(Project)
                else:
                    print("ERROR: App " + app['app_name'] + " is not linked to any CloudEndure project....")
                    sys.exit(5)
    Projects = GetServerList(newapps, servers, CEProjects, Waveid)
    return Projects

def GetServerList(apps, servers, CEProjects, Waveid):
    servercount = 0
    Projects = CEProjects
    for Project in Projects:
        ServersList = []
        for app in apps:
            if str(app['cloudendure_projectname']) == Project['ProjectName']:
                for server in servers:
                    if app['app_id'] == server['app_id']:
                        if 'server_os' in server:
                                if 'server_fqdn' in server:
                                        ServersList.append(server)
                                else:
                                    print("ERROR: server_fqdn for server: " + server['server_name'] + " doesn't exist")
                                    sys.exit(4)
                        else:
                            print ('server_os attribute does not exist for server: ' + server['server_name'] + ", please update this attribute")
                            sys.exit(2)
        Project['Servers'] = ServersList
        # print(Project)
        servercount = servercount + len(ServersList)
    if servercount == 0:
        print("ERROR: Serverlist for wave: " + Waveid + " is empty....")
        sys.exit(3)
    else:
        return Projects


def verify_replication(projects, token):
    # Get Machine List from CloudEndure
    time.sleep(10)
    auth = {"Authorization": token}
    for project in projects:
            print("")
            project_id = project['ProjectId']
            serverlist = project['Servers']
            m = requests.get(HOST + endpoint.format('projects/{}/machines').format(
                project_id), headers=headers, cookies=session)
            if "sourceProperties" not in m.text:
                print("ERROR: Failed to fetch the machines for project: " +
                      project['ProjectName'])
                sys.exit(7)
            for server in serverlist:
                machine_exist = False
                for machine in json.loads(m.text)["items"]:
                    if server["server_name"].lower() == machine['sourceProperties']['name'].lower():
                        machine_exist = True
                        replication_state = machine['replicationStatus']
                        print("CE replication status for  " + str(server["server_name"]) + "..." + replication_state )
                if machine_exist == False:
                    print(
                        "ERROR: Machine: " + server["server_name"] + " does not exist in CloudEndure....")
                    sys.exit(8)

def replication_action(projects, token, replication_action):
        # Get Machine List from CloudEndure
        auth = {"Authorization": token}
        for project in projects:
            print("")
            project_id = project['ProjectId']
            serverlist = project['Servers']
            m = requests.get(HOST + endpoint.format('projects/{}/machines').format(project_id), headers=headers, cookies=session)
            if "sourceProperties" not in m.text:
                print("ERROR: Failed to fetch the machines for project: " + project['ProjectName'])
                sys.exit(7)
            for server in serverlist:
                machine_exist = False
                for machine in json.loads(m.text)["items"]:
                    if server["server_name"].lower() == machine['sourceProperties']['name'].lower():
                        machine_exist = True
                        machine_data = {'machineIDs': [machine['id']]}
                        if replication_action.lower() == "start":
                            r = requests.post(HOST + endpoint.format('projects/{}/startReplication').format(
                                project_id), headers=headers, cookies=session, data= json.dumps(machine_data))
                            if "200" in str(r):
                                print("Replication started for machine..  " + server["server_name"])
                            else:
                                print("Replication could not be started for machine..  " + server["server_name"])
                        if replication_action.lower() == "pause":
                            r = requests.post(HOST + endpoint.format('projects/{}/pauseReplication').format(project_id), headers=headers, cookies=session, data=json.dumps(machine_data))
                            if "200" in str(r):
                                print("Replication paused for machine..  " + server["server_name"])
                            else:
                                print("Replication could not be paused for machine..  " + server["server_name"])
                        if replication_action.lower() == "stop":
                            r = requests.post(HOST + endpoint.format('projects/{}/stopReplication').format(project_id), headers=headers, cookies=session, data=json.dumps(machine_data))
                            if "200" in str(r):
                                print("Replication stopped for machine..  " + server["server_name"])
                            else:
                                print("Replication could not be stopped for machine..  " + server["server_name"])
                        if replication_action.lower() == "check":
                            pass


                if machine_exist == False:
                    print("ERROR: Machine: " + server["server_name"] + " does not exist in CloudEndure....")
                    sys.exit(8)




def main(arguments):
    print("")
    print("************************")
    print("* Login to CloudEndure *")
    print("************************")
    r = CElogin,endpoint
    if r is not None and "ERROR" in r:
        print(r)

    print("***********************")
    print("* Getting Server List *")
    print("***********************")
    Projects = ProjectList(CELogin, HOST, endpoint, projectendpoint)
    print("")
    for project in Projects:
        print("***** Servers for CE Project: " + project['ProjectName'] + " *****")
        for server in project['Servers']:
            print(server['server_name'])
        print("")
    print("")
    print("*****************************")
    print("*  " + str(ReplicationAction.upper())+ "  Replication *")
    print("*****************************")
    replication_action(Projects, token, ReplicationAction)
    print("")
    print("*****************************")
    print("* Verify replication status *")
    print("*****************************")
    verify_replication(Projects, token)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
