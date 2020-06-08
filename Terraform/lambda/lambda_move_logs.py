import json
import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):

    move_logs_to_queriedlogs(event["bucket_name"], event["fileName"])


def move_logs_to_queriedlogs(bucket_name, fileName):

    now = (datetime.now() + timedelta(hours=2))

    year = now.strftime("%Y")
    month = now.strftime("%m")
    day = now.strftime("%d")

    time = now.strftime("%H_%M")

    path_to_queriedlogs = "QueriedLogs/" + str(year) + "/" + str(month) + "/" + str(day) + "/" + str(time) + "/" + fileName


    s3_resource = boto3.resource('s3')

    s3_resource.Object(bucket_name, path_to_queriedlogs).copy_from(CopySource=bucket_name + "/Logs/" + fileName)

    s3_resource.Object(bucket_name, "Logs/" + fileName).delete()
