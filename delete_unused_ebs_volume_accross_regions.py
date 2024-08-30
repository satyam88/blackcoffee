import boto3
from botocore.exceptions import ClientError
import logging

def delete_unattached_volumes():
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger()

    ec2 = boto3.client('ec2')
    regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]

    for region in regions:
        logger.info(f"Checking region: {region}")
        ec2 = boto3.client('ec2', region_name=region)

        # Paginate through all volumes
        paginator = ec2.get_paginator('describe_volumes')
        for page in paginator.paginate():
            for volume in page['Volumes']:
                volume_id = volume['VolumeId']
                attachments = volume['Attachments']

                if not attachments:  # Volume is not attached to any instance
                    try:
                        logger.info(f"Deleting unattached volume {volume_id} in region {region}")
                        ec2.delete_volume(VolumeId=volume_id)
                    except ClientError as e:
                        logger.error(f"Could not delete volume {volume_id} in region {region}: {e}")
                else:
                    logger.info(f"Volume {volume_id} in region {region} is attached, skipping.")

def lambda_handler(event, context):
    # Main entry point for AWS Lambda
    delete_unattached_volumes()
    return {
        'statusCode': 200,
        'body': 'Completed volume deletion process'
    }
========================

1. go to configuration -- > general -> timeout change the value from 3 sec to 1 min 

2. go to runtime setting - > Handler --> delete_unused_ebs_volume_accross_regions.lambda_handler 


