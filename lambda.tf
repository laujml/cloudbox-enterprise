# ─── Lab 7: 5 funciones Lambda individuales ───────────────────────────────────

# createFile - Lab 9: modificada para enviar a SQS
data "archive_file" "create_file_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/createFile/lambda_function.py"
  output_path = "${path.root}/lambda/createFile.zip"
}

resource "aws_lambda_function" "create_file" {
  function_name    = "createFile"
  filename         = data.archive_file.create_file_zip.output_path
  source_code_hash = data.archive_file.create_file_zip.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.documents_queue.id
    }
  }
}

resource "aws_lambda_permission" "allow_create" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_file.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.files_api.execution_arn}/*/*"
}

# getFiles
data "archive_file" "get_files_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/getFiles/lambda_function.py"
  output_path = "${path.root}/lambda/getFiles.zip"
}

resource "aws_lambda_function" "get_files" {
  function_name    = "getFiles"
  filename         = data.archive_file.get_files_zip.output_path
  source_code_hash = data.archive_file.get_files_zip.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.files.name
    }
  }
}

resource "aws_lambda_permission" "allow_get_files" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_files.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.files_api.execution_arn}/*/*"
}

# getFileById
data "archive_file" "get_file_by_id_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/getFileById/lambda_function.py"
  output_path = "${path.root}/lambda/getFileById.zip"
}

resource "aws_lambda_function" "get_file_by_id" {
  function_name    = "getFileById"
  filename         = data.archive_file.get_file_by_id_zip.output_path
  source_code_hash = data.archive_file.get_file_by_id_zip.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.files.name
    }
  }
}

resource "aws_lambda_permission" "allow_get_file_by_id" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_file_by_id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.files_api.execution_arn}/*/*"
}

# updateFile
data "archive_file" "update_file_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/updateFile/lambda_function.py"
  output_path = "${path.root}/lambda/updateFile.zip"
}

resource "aws_lambda_function" "update_file" {
  function_name    = "updateFile"
  filename         = data.archive_file.update_file_zip.output_path
  source_code_hash = data.archive_file.update_file_zip.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.files.name
    }
  }
}

resource "aws_lambda_permission" "allow_update_file" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_file.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.files_api.execution_arn}/*/*"
}

# deleteFile
data "archive_file" "delete_file_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/deleteFile/lambda_function.py"
  output_path = "${path.root}/lambda/deleteFile.zip"
}

resource "aws_lambda_function" "delete_file" {
  function_name    = "deleteFile"
  filename         = data.archive_file.delete_file_zip.output_path
  source_code_hash = data.archive_file.delete_file_zip.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.files.name
    }
  }
}

resource "aws_lambda_permission" "allow_delete_file" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_file.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.files_api.execution_arn}/*/*"
}
