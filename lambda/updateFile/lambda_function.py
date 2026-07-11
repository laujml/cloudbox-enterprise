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
        body = json.loads(event.get("body") or "{}")

        # Verificar propietario antes de actualizar
        existing = table.get_item(Key={"fileId": file_id}).get("Item")
        if not existing or existing.get("ownerId") != owner_id:
            return {
                "statusCode": 403,
                "headers": CORS_HEADERS,
                "body": json.dumps({"message": "Forbidden"})
            }

        table.update_item(
            Key={"fileId": file_id},
            UpdateExpression="SET fileName = :fn, category = :cat, #sz = :sz",
            ExpressionAttributeNames={"#sz": "size"},
            ExpressionAttributeValues={
                ":fn": body.get("fileName", existing["fileName"]),
                ":cat": body.get("category", existing["category"]),
                ":sz": body.get("size", existing["size"])
            }
        )

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Archivo actualizado", "fileId": file_id})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": str(e)})
        }
