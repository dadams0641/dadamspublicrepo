#!/usr/bin/env python3
import sys 
import xml.etree.ElementTree as ET
import subprocess
import boto3
import time
import re

# Time Converter DO NOT MODIFY
def convert(seconds):
    seconds = seconds % (24 * 3600)
    hour = seconds // 3600
    seconds %= 3600
    minutes = seconds // 60
    seconds %= 60
    return "%d:%02d:%02d" % (hour, minutes, seconds)

# Build Variables
Builder = "Jenkins/Ansible"
EC2BuildPath= "/var/lib/jenkins/jobs/CICD\ Deployments\ \(AWS\)/jobs/EC2\ Deployments/jobs/Windows\ EC2\ Deployment/builds"
EC2BuildFilePath= "/var/lib/jenkins/jobs/CICD Deployments (AWS)/jobs/EC2 Deployments/jobs/Windows EC2 Deployment/builds"
LastEC2Build= "ls -lrt " + EC2BuildPath + " | awk {'print $9'} | grep ^[0-9].* | tail -1"
EC2BN = subprocess.Popen(LastEC2Build, shell=True, stdout=subprocess.PIPE)
for ebn in EC2BN.stdout:
    ebn = ebn.decode()
    ebn = ebn.rstrip()
EC2BuildNumber = ebn
BuildLog = ET.parse(EC2BuildFilePath + "/" + EC2BuildNumber + "/build.xml")
LogRoot = BuildLog.getroot()
varspath = "/opt/Cloud-Engineering/ansible/fm_win_ec2_configure/group_vars/all/"
varsfile = "vars.yml"
varsinput = open(varspath + varsfile, 'r')

# Get latest build time (in milliseconds)
BuildDurationMilliseconds = int(LogRoot.find('duration').text)
# Get latest build status (success/fail)
BuildResult = LogRoot.find('result').text.title()

if BuildResult == "Success":
    if BuildDurationMilliseconds > 1000:
        BuildDuration = BuildDurationMilliseconds / 1000
        BuildTime = str(convert(BuildDuration))
    elif BuildDurationMilliseconds < 1000:
        BuildTime = str(BuildDurationMilliseconds)
        
for vi in varsinput:
    if "end_value" in vi:
        count_check = re.findall(":(.*)", vi)
        server_count = count_check[0].replace(' ', '')
        server_count = str(server_count)
    if "ticket_number" in vi:
        ticket_check = re.findall(":(.*)", vi)
        ticket_number = ticket_check[0].replace(' ', '')
        if ticket_number != "None":
            ticket_number = str(ticket_number)
        else:
            pass
    if "name" in vi and "-" in vi and "_" not in vi:
        name_check = re.findall(":(.*)", vi)
        server_name = name_check[0].replace(' ', '')
    if "platform" in vi:
        platform_check = re.findall(":(.*)", vi)
        platform = platform_check[0].replace(' ', '')
    if "environment" in vi:
        envvarname = re.findall(":(.*)", vi)
        envvar = envvarname[0]
        envvar = envvar.lower()
        envvar = envvar.lstrip()
        if envvar == "dev":
            env = "Dev"
        elif envvar == "prod": 
            env = "Production"
        else:
            env = envvar.Title()    


if int(server_count) > 1:
    server = "servers"
else:
    server = "server"
    
print(Builder, ticket_number, server_name, server_count, platform, env, BuildTime)
