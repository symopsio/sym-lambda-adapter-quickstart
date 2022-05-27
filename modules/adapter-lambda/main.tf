locals {
  api_key_path = "/symops.com/${var.function_name}/API_KEY"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name

  filename = "${path.module}/handler/dist/handler.zip"
  handler  = "handler.handle"
  runtime  = "python3.8"

  environment {
    variables = {
      "API_KEY_PATH" = local.api_key_path
      "API_URL"      = var.api_url
    }
  }

  role = aws_iam_role.this.arn

  timeout = 3

  tags = var.tags

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      source_code_size,
    ]
  }
}

resource "aws_ssm_parameter" "api_key" {
  name  = local.api_key_path
  type  = "SecureString"
  value = "CHANGEME"

  lifecycle {
    ignore_changes = [value, version]
  }
}
