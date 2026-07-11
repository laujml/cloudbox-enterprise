# Lab 7 - Amazon Cognito para autenticación empresarial
resource "aws_cognito_user_pool" "users" {
  name                     = "CloudBoxUsers"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  mfa_configuration = "OFF"

  tags = {
    Project = var.project_name
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name            = "CloudBoxClient"
  user_pool_id    = aws_cognito_user_pool.users.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}
