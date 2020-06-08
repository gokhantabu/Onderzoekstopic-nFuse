import json
import boto3
import time
from datetime import datetime, timedelta

DATABASE = "mylogstf"
TABLE = "raw_logs_nginxtf"
S3_OUTPUT = 's3://stage-demo-nfuse.453882275279/OutputAthena/'
S3_BUCKET = 'stage-demo-nfuse.453882275279'
RETRY_COUNT = 20


def lambda_handler(event, context):

    #Load previous info from the lambda
    tempstr = str(event).replace("\'", "\"")
    objectTrigger = json.loads(tempstr)


    #Execute query
    result = query_logs()


    #Count for errors and save into objectTrigger
    count_rows = len(result['ResultSet']['Rows'])

    if count_rows == 1:
        return "No errors found"

    objectTrigger['errorsFound'] = count_rows - 1

    resultTrigger = {
        "bucket_name": objectTrigger["bucket_name"],
        "result": result['ResultSet']['Rows'],
        "fileName": objectTrigger["fileName"]
    }


    #Invoke lambdas
    invoke_lambda_save_json(resultTrigger)


    invoke_lambda_sns(objectTrigger)


def execute_query_athena(query):
    client = boto3.client('athena')

    response = client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={
            'Database': DATABASE
        },
        ResultConfiguration={
            'OutputLocation': S3_OUTPUT,
        }
    )

    query_execution_id = response['QueryExecutionId']

    for i in range(1,1 + RETRY_COUNT):

        query_status = client.get_query_execution(QueryExecutionId=query_execution_id)
        query_execution_status = query_status['QueryExecution']['Status']['State']

        if query_execution_status == 'SUCCEEDED':
            print("STATUS:" + query_execution_status + " - " + query_execution_id)

            result = client.get_query_results(QueryExecutionId=query_execution_id)
            return result

        if query_execution_status == 'FAILED':
            raise Exception("STATUS:" + query_execution_status)

        else:
            print("STATUS:" + query_execution_status + " - " + query_execution_id)
            time.sleep(i)

    client.stop_query_execution(QueryExecutionId=query_execution_id)
    raise Exception('TIME OVER')


def query_logs():

    query = "SELECT * FROM " + DATABASE + "." + TABLE + " WHERE error_type LIKE '%error%'"
    print(query)
    result = execute_query_athena(query)

    return result


def invoke_lambda_save_json(context):
    lambda_client = boto3.client('lambda')

    lambda_client.invoke(FunctionName="lambda_save_jsonTF",
    InvocationType='Event',
    LogType='None',
    Payload=json.dumps(context))


def invoke_lambda_sns(context):

    lambda_client = boto3.client('lambda')

    lambda_client.invoke(FunctionName="lambda_sns_publishTF",
    InvocationType='Event',
    LogType='None',
    Payload=json.dumps(context))