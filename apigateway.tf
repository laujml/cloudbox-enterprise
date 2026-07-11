# Lab 7 - API REST FilesAPI
resource "aws_api_gateway_rest_api" "files_api" {
  name        = "FilesAPI"
  description = "API REST para gestión de archivos CloudBox"
}

# Lab 7 - Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name            = "CloudBoxAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.files_api.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.users.arn]
}

# ─── Recursos de ruta ────────────────────────────────────────────────────────

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  parent_id   = aws_api_gateway_rest_api.files_api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "files"
}

resource "aws_api_gateway_resource" "file_id" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  parent_id   = aws_api_gateway_resource.files.id
  path_part   = "{id}"
}

# ─── POST /v1/files → createFile ─────────────────────────────────────────────

resource "aws_api_gateway_method" "post_files" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "create_file" {
  rest_api_id             = aws_api_gateway_rest_api.files_api.id
  resource_id             = aws_api_gateway_resource.files.id
  http_method             = aws_api_gateway_method.post_files.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_file.invoke_arn
}

# ─── GET /v1/files → getFiles ────────────────────────────────────────────────

resource "aws_api_gateway_method" "get_files" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_files" {
  rest_api_id             = aws_api_gateway_rest_api.files_api.id
  resource_id             = aws_api_gateway_resource.files.id
  http_method             = aws_api_gateway_method.get_files.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_files.invoke_arn
}

# ─── GET /v1/files/{id} → getFileById ────────────────────────────────────────

resource "aws_api_gateway_method" "get_file_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.file_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_file_by_id" {
  rest_api_id             = aws_api_gateway_rest_api.files_api.id
  resource_id             = aws_api_gateway_resource.file_id.id
  http_method             = aws_api_gateway_method.get_file_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_file_by_id.invoke_arn
}

# ─── PUT /v1/files/{id} → updateFile ─────────────────────────────────────────

resource "aws_api_gateway_method" "update_file" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.file_id.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "update_file" {
  rest_api_id             = aws_api_gateway_rest_api.files_api.id
  resource_id             = aws_api_gateway_resource.file_id.id
  http_method             = aws_api_gateway_method.update_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_file.invoke_arn
}

# ─── DELETE /v1/files/{id} → deleteFile ──────────────────────────────────────

resource "aws_api_gateway_method" "delete_file" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.file_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "delete_file" {
  rest_api_id             = aws_api_gateway_rest_api.files_api.id
  resource_id             = aws_api_gateway_resource.file_id.id
  http_method             = aws_api_gateway_method.delete_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_file.invoke_arn
}

# ─── OPTIONS /v1/files (CORS) ────────────────────────────────────────────────

resource "aws_api_gateway_method" "options_files" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_files" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.options_files.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_files_200" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.options_files.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_files_200" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.options_files.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,DELETE,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.options_files,
    aws_api_gateway_method_response.options_files_200
  ]
}

# ─── Lab 7: API Key + Usage Plan ─────────────────────────────────────────────

resource "aws_api_gateway_api_key" "files_api_key" {
  name    = "FilesAPIKey"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "files_usage_plan" {
  name = "FilesUsagePlan"

  throttle_settings {
    burst_limit = 20
    rate_limit  = 10
  }

  api_stages {
    api_id = aws_api_gateway_rest_api.files_api.id
    stage  = aws_api_gateway_stage.dev.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.files_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.files_usage_plan.id
}

# ─── Deployment y Stage dev ──────────────────────────────────────────────────

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id

  depends_on = [
    aws_api_gateway_integration.create_file,
    aws_api_gateway_integration.get_files,
    aws_api_gateway_integration.get_file_by_id,
    aws_api_gateway_integration.update_file,
    aws_api_gateway_integration.delete_file,
    aws_api_gateway_integration.options_files
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  stage_name    = "dev"
}
