output "lambda_arn" {
  description = "The arn of the lambda function"
  value       = aws_lambda_function.sym_quickstart_lambda.arn
}
