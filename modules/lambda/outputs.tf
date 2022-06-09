output "lambda_arn" {
  description = "The arn of the lambda function"
  value       = aws_lambda_function.sym_quickstart_lambda.arn
}

output "api_key_arn" {
  description = "The arn of the SSM Parameter containin the API Key used by the lambda function"
  value = aws_ssm_parameter.api_key.arn
}
