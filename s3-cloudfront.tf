# Lab 8 - S3 + CloudFront para el frontend React

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Lab 8: Generar .env.production automáticamente con los valores de Cognito y API
# join() evita espacios iniciales que romperían el parsing de Vite
resource "local_file" "env_production" {
  filename = "${path.root}/frontend/.env.production"
  content = join("\n", [
    "VITE_API_URL=${aws_api_gateway_stage.dev.invoke_url}/v1",
    "VITE_USER_POOL_ID=${aws_cognito_user_pool.users.id}",
    "VITE_CLIENT_ID=${aws_cognito_user_pool_client.client.id}",
    "VITE_REGION=${var.aws_region}",
    ""
  ])
}

# Lab 8: Build automático del proyecto React
resource "null_resource" "react_build" {
  depends_on = [local_file.env_production]

  provisioner "local-exec" {
    working_dir = "${path.root}/frontend"
    command     = "npm install && npm run build"
  }
}

# Lab 8: Bucket S3 principal
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-${random_string.suffix.result}"

  tags = {
    Project     = var.project_name
    Environment = "lab"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Lab 8: Habilitar versionamiento
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lab 8: Configurar website hosting
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}

# Lab 8: Deshabilitar bloqueo público
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Lab 8: Política de lectura pública
resource "aws_s3_bucket_policy" "frontend" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.frontend.arn}/*"]
      }
    ]
  })
}

# Lab 8: Subir index.html
resource "aws_s3_object" "index" {
  depends_on   = [null_resource.react_build]
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.root}/frontend/dist/index.html"
  content_type = "text/html"
}

# Lab 8: Subir assets con aws s3 sync
# Usa PowerShell + Set-Location para evitar el problema de paths relativos en Windows
resource "null_resource" "sync_assets" {
  depends_on = [null_resource.react_build, aws_s3_bucket_policy.frontend]

  triggers = {
    build_id = null_resource.react_build.id
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "Set-Location frontend/dist; aws s3 sync . s3://${aws_s3_bucket.frontend.id} --delete"
  }
}

# Lab 8: Distribución CloudFront
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend.website_endpoint
    origin_id   = "frontend-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "frontend-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Lab 8: Invalidación de caché tras cada despliegue
resource "null_resource" "cloudfront_invalidation" {
  depends_on = [aws_s3_object.index, null_resource.sync_assets]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.frontend.id} --paths '/*'"
  }
}
