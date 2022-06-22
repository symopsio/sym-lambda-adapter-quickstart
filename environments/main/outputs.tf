output "adapter_lambda_arn" {
  description = "The arn of the lambda function"
  value       = module.adapter_flow.lambda_arn
}
