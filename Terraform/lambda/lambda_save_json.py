import json
import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):


    save_file_to_s3(event["fileName"], event["result"], event["bucket_name"])


def save_file_to_s3(fileName, result, bucket_name):

    s = (datetime.now() + timedelta(hours=2)).strftime('%Y/%m/%d/%H:%M:%S.%f')

    split_file = fileName.split(".")

    file_name = str(s) + "-" + split_file[0]

    file_path = 'StructuredAthena/' + file_name + '.json'

    s3 = boto3.resource("s3").Bucket(bucket_name)


    json.dump_s3 = lambda obj, f: s3.Object(key=f).put(Body=json.dumps(obj))
    json.dump_s3(result, file_path)