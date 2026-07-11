import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,PUT,OPTIONS"
}


def lambda_handler(event, context):
    try:
        claims = (event.get("requestContext") or {}).get("authorizer", {}).get("claims", {})
        owner_id = claims.get("sub", "")
        file_id = (event.get("pathParameters") or {}).get("id", "")

        # Verificar propietario antes de eliminar
        existing = table.get_item(Key={"fileId": file_id}).get("Item")
        if not existing or existing.get("ownerId") != owner_id:
            return {
                "statusCode": 403,
                "headers": CORS_HEADERS,
                "body": json.dumps({"message": "Forbidden"})
            }

        # Eliminación lógica: status = DELETED (no se borra el registro)
        table.update_item(
            Key={"fileId": file_id},
            UpdateExpression="SET #st = :deleted",
            ExpressionAttributeNames={"#st": "status"},
            ExpressionAttributeValues={":deleted": "DELETED"}
        )

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Archivo eliminado", "fileId": file_id})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": str(e)})
        }
