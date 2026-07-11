# Lab 7 - Rol IAM base para todas las Lambdas
resource "aws_iam_role" "lambda_role" {
  name = "cloudbox-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lab 7 - Política DynamoDB (CRUD completo)
resource "aws_iam_policy" "dynamodb_policy" {
  name = "cloudbox-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.files.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# Lab 9 - Permiso para que la Lambda productora envíe mensajes a SQS
resource "aws_iam_role_policy" "producer_sqs_policy" {
  name = "producer-sqs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.documents_queue.arn
      }
    ]
  })
}

# Lab 9 - Permiso para que la Lambda consumidora lea de SQS
resource "aws_iam_role_policy" "consumer_sqs_policy" {
  name = "consumer-sqs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.documents_queue.arn
      }
    ]
  })
}

# Lab 9 - Permiso adicional PutItem para Lambda consumidora
resource "aws_iam_role_policy" "consumer_dynamodb_policy" {
  name = "consumer-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.files.arn
      }
    ]
  })
}
