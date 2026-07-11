import json
import boto3
import os
import uuid

dynamodb = boto3.resource("dynamodb")
sqs = boto3.client("sqs")

TABLE_NAME = os.environ.get("TABLE_NAME", "documents")
QUEUE_URL = os.environ["QUEUE_URL"]

table = dynamodb.Table(TABLE_NAME)

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS"
}


def lambda_handler(event, context):
    method = event.get("httpMethod", "")
    path = event.get("path", "")

    if method == "OPTIONS":
        return {"statusCode": 200, "headers": CORS_HEADERS, "body": ""}

    # GET /v1/files - consultar todos los documentos desde DynamoDB
    if method == "GET" and path.endswith("/files"):
        response = table.scan()
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(response["Items"])
        }

    # POST /v1/files - enviar mensaje a SQS (Lab 9: desacoplado de DynamoDB)
    if method == "POST" and path.endswith("/files"):
        body = json.loads(event.get("body", "{}"))
        body["fileId"] = str(uuid.uuid4())

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(body)
        )

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Message queued"})
        }

    # DELETE /v1/files/{id} - eliminar documento directamente de DynamoDB
    if method == "DELETE" and "/files/" in path:
        file_id = path.split("/files/")[-1]
        table.delete_item(Key={"fileId": file_id})

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "File deleted"})
        }

    return {
        "statusCode": 404,
        "headers": CORS_HEADERS,
        "body": json.dumps({"message": "Not found"})
    }
