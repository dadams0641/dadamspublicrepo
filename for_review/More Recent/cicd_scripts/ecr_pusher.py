#!/bin/env python3

import json
import subprocess
import datetime
from datetime import date
import boto3
import botocore
import sys

y=0
DEFAULT_RESOURCE_TYPE = 'AWS::::Account'
ASSUME_ROLE_MODE = False
a = boto3.client('ecr')
stsid = boto3.client('sts')
idcheck=stsid.get_caller_identity()
acct=idcheck['Account']
acct=str(acct)

ecr_images = a.list_images(registryId=
