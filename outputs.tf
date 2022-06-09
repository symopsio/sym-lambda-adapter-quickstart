output "lambda_arn" {
  description = "The arn of the lambda function"
  value       = module.lambda_handler.lambda_arn
}

output "api_key_arn" {
  description = "The arn of the SSM Parameter containing the API Key used by the lambda function"
  value = module.lambda_handler.api_key_arn
}
