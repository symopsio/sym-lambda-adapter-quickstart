output "api_key_path" {
  description = "The name of the SSM Parameter with your API Key"
  value       = local.api_key_path
}

output "lambda_arn" {
  description = "The arn of the lambda function"
  value       = aws_lambda_function.this.arn
}
