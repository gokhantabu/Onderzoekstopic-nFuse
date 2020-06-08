import json
import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):

    #Get the information of the uploaded logfile
    for i in event["Records"]:
        action = i["eventName"]
        ip = i["requestParameters"]["sourceIPAddress"]
        bucket_name = i["s3"]["bucket"]["name"]
        path = i["s3"]["object"]["key"]


    #Split path to get filename
    split_path = path.split("/")
    fileName = split_path[1]


    #Pass the values into a dictionary
    objectTrigger = {
        "action": action,
        "ip": ip,
        "bucket_name": bucket_name,
        "fileName": fileName
    }


    #execute function to register into DynamoDB
    put_item_dynamodb(fileName)

    #invoke the Athena query lambda
    invoke_lambda_function(str(objectTrigger))


def put_item_dynamodb(fileName):

    dynamodb = boto3.client('dynamodb')

    now = (datetime.now() + timedelta(hours=2))

    logsId = now.strftime('%Y%m%d_%H%M%S.%f')
    regDate = now.strftime("%Y-%m-%d")
    regTime= now.strftime("%H:%M")

    dynamodb.put_item(TableName='RegistrationLogsTF', Item={'logsId':{'S':logsId},
    'fileName':{'S':fileName},
    'registrationDate':{'S':regDate},
    'registrationTime':{'S':regTime}})

    print('Succesfully added to DB')

def invoke_lambda_function(context):

    lambda_client = boto3.client('lambda')

    lambda_client.invoke(FunctionName="lambda_queryTF", InvocationType='Event', LogType='None', Payload=json.dumps(context))