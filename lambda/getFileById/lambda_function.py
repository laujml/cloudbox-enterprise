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
        file_id = (event.get("pathParameters") or {}).get("id", "")

        response = table.get_item(Key={"fileId": file_id})
        item = response.get("Item")

        if not item or item.get("ownerId") != owner_id:
            return {
                "statusCode": 403,
                "headers": CORS_HEADERS,
                "body": json.dumps({"message": "Forbidden"})
            }

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(item, default=decimal_default)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": str(e)})
        }
