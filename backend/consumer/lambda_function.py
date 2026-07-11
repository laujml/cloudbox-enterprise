import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    for record in event["Records"]:
        body = json.loads(record["body"])
        table.put_item(Item=body)

    return {"statusCode": 200}
