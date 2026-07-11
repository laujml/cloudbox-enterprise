# ─── Lab 7 Outputs ────────────────────────────────────────────────────────────
output "api_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/v1"
}

output "user_pool_id" {
  value = aws_cognito_user_pool.users.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.files.name
}

output "region" {
  value = var.aws_region
}

output "api_key" {
  value     = aws_api_gateway_api_key.files_api_key.value
  sensitive = true
}

# ─── Lab 8 Outputs ────────────────────────────────────────────────────────────
output "frontend_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

# ─── Lab 9 Outputs ────────────────────────────────────────────────────────────
output "documents_dlq_url" {
  value = aws_sqs_queue.documents_dlq.id
}
