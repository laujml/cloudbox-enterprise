# Lab 9 - Parte 3: Lambda Consumidora (SQS → DynamoDB)

data "archive_file" "consumer_zip" {
  type        = "zip"
  source_file = "${path.root}/backend/consumer/lambda_function.py"
  output_path = "${path.root}/consumer.zip"
}

resource "aws_lambda_function" "consumer" {
  filename         = data.archive_file.consumer_zip.output_path
  source_code_hash = data.archive_file.consumer_zip.output_base64sha256
  function_name    = "documents-consumer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.files.name
    }
  }
}

# Lab 9 - Event Source Mapping: invoca Lambda cuando hay mensajes en SQS
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.documents_queue.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}
