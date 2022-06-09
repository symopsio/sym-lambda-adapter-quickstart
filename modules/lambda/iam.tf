# This resource will create an AWS IAM Role the Lambda will assume upon execution.
resource "aws_iam_role" "lambda_execution_role" {
  name = "sym-lambda-quickstart-execution-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}

# This resource attaches the following IAM Policy to the Lambda Execution Role.
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}


# Get the AWS Account ID this Lambda is running in.
data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}

# The IAM Policy for the Lambda Execution Role.
# Allows the Lambda to send logs to Cloudwatch and get parameters from SSM
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "sym-lambda-quickstart-execution-policy"
  description = "Sym AWS lambda Quickstart Execution Policy"

  policy = jsonencode({
    Statement = [
      {
        # Cloudwatch permissions
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:*:${local.account_id}:log-group:/aws/lambda/${var.function_name}*:*"
        ]
      },
      {
        # SSM Get Parameter permissions
        Action = [
          "ssm:GetParameter*"
        ],
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:*:${local.account_id}:parameter/symops.com/${var.function_name}/*"
        ]
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}
