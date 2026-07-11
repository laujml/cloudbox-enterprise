# Lab 9 - Parte 1: Dead Letter Queue
resource "aws_sqs_queue" "documents_dlq" {
  name = "documents-dlq"
}

# Lab 9 - Parte 1: Cola principal con redrive hacia DLQ
resource "aws_sqs_queue" "documents_queue" {
  name                       = "documents-queue"
  visibility_timeout_seconds = 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.documents_dlq.arn
    maxReceiveCount     = 3
  })
}

output "documents_queue_url" {
  value = aws_sqs_queue.documents_queue.id
}

output "documents_queue_arn" {
  value = aws_sqs_queue.documents_queue.arn
}
