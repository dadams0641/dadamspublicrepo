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

'''
roleArnList = ['']

'''

roleArnList = ['']
elb_list = ["amz-edm-static-02-lb",
"amz-pedmlb01",
"amz-pibmbpmwslb01-ret",
"amz-pibmbpmwslb01-whl",
"amz-pibmbpmwslb03-spg",
"lkw-services-static-01-lb",
"plkw-services-prod-alb",
"pedmlb01"
]


for rA in roleArnList:
    roleArn = rA
    print("Operating under Role ARN: " + roleArn)
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
    tsvout = open(aN.upper() + '_Appranix_EC2.tsv', 'a')
    tsvout.write('Account ID\tAppranix Name\tInstance ID\tInstance State\tInstance Type\tVolume Info\tTags\n')
    describe_instances = ec2.describe_instances()
    for di in describe_instances['Reservations']:
        for dii in di['Instances']:
            instance_tags = dii['Tags']
            for it in instance_tags:
                itags = it.values()
                if "Name" in itags and "AppName" not in itags:
                    itagstr = str(itags)
                    split_itagstr = itagstr.split(',')
                    appranix_name = split_itagstr[1].strip('[\]\)\']')
                    instances = dii['InstanceId']
                    tags=dii['Tags']
                    instance_state=dii['State']['Name']
                    instance_state=instance_state.title()
                    instance_type = dii['InstanceType']
                    volumeid = dii['BlockDeviceMappings']
                    volume_data = []
                    for vid in volumeid:
                        volume_id = vid['Ebs']['VolumeId']
                        volume_name = vid['DeviceName']
                        describe_volumes = ec2.describe_volumes(VolumeIds=[volume_id])
                        for dv in describe_volumes['Volumes']:
                            volume_size = dv['Size']
                            volume_size = str(volume_size)
                            volume_size = volume_size + "GB"
                            volume_data.append(volume_name + " | " + volume_id + " | " + volume_size)
                    print(AccountID + "-" + aN + "\t" + appranix_name + "\t" + instances + "\t" + instance_state + "\t" + instance_type + "\t" +  str(volume_data) + "\t" + str(tags) + "\n")
                    tsvout.write(AccountID + "-" + aN + "\t" + appranix_name + "\t" + instances + "\t" + instance_state + "\t" + instance_type + "\t" +  str(volume_data) + "\t" + str(tags) + "\n")
    tsvout.close()
    tsvout = open(aN.upper() + '_Appranix_ELB.tsv', 'a')
    tsvout.write('Account ID\tLoad Balancer Name\tLoad Balancer ARN\tLoad Balancer State\tLoad Balancer Sceme\tVPC ID\tTags\n')
    describe_load_balancers=elb.describe_load_balancers(Names=elb_list)
    for dlb in describe_load_balancers['LoadBalancers']:
        lb_name = dlb['LoadBalancerName']
        lb_arn = dlb['LoadBalancerArn']
        lb_scheme = dlb['Scheme']
        lb_vpc_id = dlb['VpcId']
        lb_state = dlb['State']['Code']
        describe_tags = elb.describe_tags(ResourceArns=[lb_arn])
        for dt in describe_tags['TagDescriptions']:
            dtags = dt['Tags']
        print(AccountID + "-" + aN + "\t" + lb_name + "\t" + lb_arn + "\t" + lb_state + "\t" + lb_scheme + "\t" + lb_vpc_id + "\t" + str(dtags) + "\n")
        tsvout.write(AccountID + "-" + aN + "\t" + lb_name + "\t" + lb_arn + "\t" + lb_state + "\t" + lb_scheme + "\t" +  lb_vpc_id + "\t" + str(dtags) + "\n")
    tsvout.close()
    tsvout = open(aN.upper() + '_Appranix_RDS.tsv', 'a')
    tsvout.write('Account ID\tDatabase Name\tInstance Class\tDatabase State\tDatabase Endpoint\tVPC ID\tTags\n')
    describe_databases = rds.describe_db_instances()
    for dd in describe_databases['DBInstances']:
        tags = dd['TagList']
        for tag in tags:
            tagvalue = tag.values()
            if "Appranix" in tagvalue:
                db_name = dd['DBInstanceIdentifier']
                db_instance_class = dd['DBInstanceClass']
                db_status = dd['DBInstanceStatus']
                db_endpoint = dd['Endpoint']
                db_endpoint = str(db_endpoint)
                db_vpc = dd['DBSubnetGroup']['VpcId']
                db_tags = dd['TagList']
                db_tags = str(db_tags)
                print(AccountID + "-" + aN + "\t" + db_name + "\t" + db_instance_class + "\t" + db_status + "\t" + db_endpoint + "\t" + db_vpc + "\t" + db_tags + "\n")
                tsvout.write(AccountID + "-" + aN + "\t" + db_name + "\t" + db_instance_class + "\t" + db_status + "\t" + db_endpoint + "\t" + db_vpc + "\t" + db_tags + "\n")
    tsvout.close()