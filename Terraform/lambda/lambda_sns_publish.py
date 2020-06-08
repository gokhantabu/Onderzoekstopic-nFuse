import json
import boto3
from datetime import datetime

TOPIC_ARN = "arn:aws:sns:eu-west-1:453882275279:NotifyLogsTF"

def lambda_handler(event, context):

    #create subject and body
    subject, body = create_subject_and_body(event)


    # publishing topic for email notification
    publish_topic(subject, body)

    #invoking lambda to move logs
    invoke_lambda_move_logs(event)

def create_subject_and_body(event):

    s= datetime.now().strftime('%Y/%m/%d')

    path_to_structured = "s3://" + event["bucket_name"] + "/StructuredAthena/" + str(s)


    # Creating subject & body for email
    subject = str(event["action"]) + "Event from " + event["bucket_name"]


    body = """
    This email is to notify you regarding {} event,
    Source IP: {},
    FileName: {},
    This file has {} error(s),
    Please go to {} for a structured view of the errors.
    """.format(event["action"], event["ip"],
    event["fileName"],
    event["errorsFound"],
    path_to_structured)

    return subject, body

def publish_topic(subject, body):

    client = boto3.client("sns")

    client.publish(
        TopicArn = TOPIC_ARN,
        Subject = subject,
        Message=body
    )

def invoke_lambda_move_logs(context):
    lambda_client = boto3.client('lambda')

    lambda_client.invoke(FunctionName="lambda_move_logsTF",
    InvocationType='Event',
    LogType='None',
    Payload=json.dumps(context))