import boto3
import datetime

ec = boto3.client('ec2')

def lambda_handler(event, context):
    # Get the current UTC time
    current_time = datetime.datetime.utcnow()

    reservations = ec.describe_instances(
        Filters=[
            {'Name': 'tag-key', 'Values': ['backup', 'Backup', 'satyam']},
        ]
    ).get(
        'Reservations', []
    )

    instances = sum(
        [
            [i for i in r['Instances']]
            for r in reservations
        ], [])

    print("Found %d instances that need backing up" % len(instances))

    for instance in instances:
        for dev in instance['BlockDeviceMappings']:
            if dev.get('Ebs', None) is None:
                continue
            vol_id = dev['Ebs']['VolumeId']
            print("Found EBS volume %s on instance %s" % (
                vol_id, instance['InstanceId']))

            # Create a snapshot
            snapshot = ec.create_snapshot(
                VolumeId=vol_id
            )

            # Calculate the age of the snapshot
            snapshot_time = snapshot['StartTime']
            age = current_time - snapshot_time.replace(tzinfo=None)

            # If the snapshot is one day old or older, delete it
            if age.days >= 1:
                ec.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
                print(f"Deleted snapshot {snapshot['SnapshotId']} as it was older than 1 day.")

# Uncomment the next line to call the lambda_handler function locally for testing purposes.
# lambda_handler(None, None)
