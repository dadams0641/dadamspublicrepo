import boto3
from pprint import pprint
import dotenv
import os
import datetime
import dateutil
from dateutil import parser
from datetime import date, timedelta

# load the environment variables
dotenv.load_dotenv()

boto_sts=boto3.client('sts')

stsresponse = boto_sts.assume_role(
    RoleArn="",
    RoleSessionName='newsession'
)

newsession_id = stsresponse["Credentials"]["AccessKeyId"]
newsession_key = stsresponse["Credentials"]["SecretAccessKey"]
newsession_token = stsresponse["Credentials"]["SessionToken"]

# create boto3 client for ec2
client = boto3.client('ec2',
                      region_name=os.getenv('AWS_REGION'),
                      aws_access_key_id=newsession_id,
                      aws_secret_access_key=newsession_key,
                      aws_session_token=newsession_token )

volumes_to_delete = list()
volumes_not_to_delete = list()

# call describe_volumes() method of client to get the details of all ebs volumes in given region
# if you have large number of volumes then get the volume detail in batch by using nextToken and process accordingly
volume_detail = client.describe_volumes()

#print volume_detail

sdate = date(2014,1,1)   # start date
edate = date(2018,12,31)   # end date

# process each volume in volume_detail
if volume_detail['ResponseMetadata']['HTTPStatusCode'] == 200:
    for each_volume in volume_detail['Volumes']:
        # some logging to make things clear about the volumes in your existing system
        print("Working for volume with volume_id: ", each_volume['VolumeId'])
        vdate = (each_volume['CreateTime']).date()
        print("State of volume: ", each_volume['State'])
        print("Attachment state length: ", len(each_volume['Attachments']))
        print(each_volume['Attachments'])
        print("--------------------------------------------")
        # figuring out the unused volumes
        # the volumes which do not have 'Attachments' key and their state is 'available' is considered to be unused
        if len(each_volume['Attachments']) == 0 and each_volume['State'] == 'available'and sdate <= vdate <= edate:
            print("Volume created before 2018: ", each_volume['VolumeId'])
            volumes_to_delete.append(each_volume['VolumeId'])
        else:
           print("Volume created after 2018: ", each_volume['VolumeId'])
           volumes_not_to_delete.append(each_volume['VolumeId'])

        #if len(each_volume['Attachments']) == 0 and each_volume['State'] == 'available':
        #    volumes_to_delete.append(each_volume['VolumeId'])

# these are the candidates to be deleted by maintaining waiters for them
pprint(volumes_to_delete)
pprint(volumes_not_to_delete)