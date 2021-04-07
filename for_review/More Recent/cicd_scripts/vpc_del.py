#!/bin/env python

import boto3
import sys

x = 0
nodel=[]

vpcdict ={
    "eu-north-1": "vpc-dc29c7b5",
    "us-east-1": "vpc-fac01c80"
}

def vpcdelete():
    for vd in vpcdict:
        setup = boto3.client('ec2', region_name=vd)
        vpcid=vpcdict[vd]
        vpc = setup.describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpcid,]}])
        descvpc = setup.describe_vpcs(VpcIds=[vpcid,],)
        sgid = vpc['SecurityGroups'][0]['GroupId']
        rt = setup.describe_route_tables()
        rtid = rt['RouteTables'][0]['RouteTableId']
        subnet = setup.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpcid,]},],)
        igsetup = setup.describe_internet_gateways(Filters=[{'Name': 'attachment.vpc-id', 'Values': [vpcid,]}])
        try:
            igid = igsetup['InternetGateways'][0]['InternetGatewayId']
            print "Detatching Internet Gateway"
            dtchigw = setup.detach_internet_gateway(InternetGatewayId=igid, VpcId=vpcid)
            print "Deleting Internet Gateway"
            delig = setup.delete_internet_gateway(InternetGatewayId=igid)
        except:
            print "No Internet Gateway Deletable."
            pass
        for st in subnet['Subnets']:
            stid = st['SubnetId']
            print "Deleting Subnet " + stid
            stdel = setup.delete_subnet(SubnetId=stid)
            print stdel
        try:
            print "Deleting VPC " + vpcid
            delvpc = setup.delete_vpc(VpcId=vpcid)
            print "VPC with ID " + vpcid + " Successfully Deleted!" 
        except:
            print "Unable to Delete VPC " + vpcid
            pass

vpcdelete()
