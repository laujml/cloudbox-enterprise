import json
import boto3
import os
import uuid
from datetime import datetime
from decimal import Decimal

# Lab 9: createFile modificado para enviar a SQS en lugar de DynamoDB directamente
sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,PUT,OPTIONS"
}


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
        claims = (event.get("requestContext") or {}).get("authorizer", {}).get("claims", {})

        file_name = body.get("fileName", "").strip()
        category = body.get("category", "").strip()
        size = body.get("size", 0)

        # Lab 7 validaciones
        if not file_name:
            return {"statusCode": 400, "headers": CORS_HEADERS,
                    "body": json.dumps({"message": "fileName es obligatorio"})}
        if not category:
            return {"statusCode": 400, "headers": CORS_HEADERS,
                    "body": json.dumps({"message": "category es obligatorio"})}
        if int(size) < 0:
            return {"statusCode": 400, "headers": CORS_HEADERS,
                    "body": json.dumps({"message": "size no puede ser negativo"})}

        item = {
            "fileId": str(uuid.uuid4()),
            "ownerId": claims.get("sub", "unknown"),
            "fileName": file_name,
            "category": category,
            "size": size,
            "status": "ACTIVE",
            "uploadDate": datetime.utcnow().isoformat()
        }

        # Lab 9: Enviar a SQS en lugar de PutItem directamente
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(item)
        )

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Message queued", "fileId": item["fileId"]})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": str(e)})
        }
