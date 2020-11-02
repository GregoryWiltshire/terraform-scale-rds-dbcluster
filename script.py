import boto3
import json
import os


def handler(event, context):
    with open('config.json','r') as f:
        config = json.loads(f.read())
        client = boto3.client('rds')
        if os.environ['TARGET_CLUSTER']:
            clusters = [ os.environ['TARGET_CLUSTER'] ]
        else:
            clusters = [ c['DBClusterIdentifier'] for c in client.describe_db_clusters()['DBClusters'] if c['ScalingConfigurationInfo'] != config ]
        if len(clusters) > 0:
            for id in clusters:
                response = client.modify_db_cluster(
                    DBClusterIdentifier=id,
                    ScalingConfiguration=config,
                    ApplyImmediately=True
                )
                print(f'Modified Cluster: {id} with config: {config}')
        else:
            print('no clusters found')
