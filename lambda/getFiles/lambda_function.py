import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,PUT,OPTIONS"
}


def decimal_default(obj):
    if isinstance(obj, Decimal):
        return str(obj)
    raise TypeError


def lambda_handler(event, context):
    try:
        claims = (event.get("requestContext") or {}).get("authorizer", {}).get("claims", {})
        owner_id = claims.get("sub", "")

        response = table.scan()
        files = [
            item for item in response.get("Items", [])
            if item.get("ownerId") == owner_id and item.get("status") == "ACTIVE"
        ]

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(files, default=decimal_default)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": str(e)})
        }
