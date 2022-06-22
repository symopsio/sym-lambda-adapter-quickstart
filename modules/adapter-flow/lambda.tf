locals {
  account_id    = data.aws_caller_identity.current.account_id
  function_name = "sym-${local.flow_name}"
  runtime       = "python3.8"

  lambda_vars = merge(
    { environment = var.sym_environment.name },
    var.lambda_vars
  )
}

resource "aws_lambda_function" "this" {
  function_name = local.function_name

  filename = data.archive_file.handler.output_path
  handler  = "handler.handle"
  runtime  = local.runtime

  environment {
    variables = local.lambda_vars
  }

  layers = [aws_lambda_layer_version.this.arn]

  role = aws_iam_role.this.arn

  timeout = 3

  tags = var.tags
}

resource "aws_lambda_layer_version" "this" {
  filename   = data.archive_file.layer.output_path
  layer_name = local.function_name

  compatible_runtimes = [local.runtime]
}

resource "aws_iam_role" "this" {
  name = "${local.function_name}-execution"

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

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "this" {
  name        = "${local.function_name}-execution"
  description = "${local.function_name} execution policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect = "Allow"
      Resource = [
        "arn:aws:logs:*:${local.account_id}:log-group:/aws/lambda/${local.function_name}*:*"
      ]
      }, {
      Action = [
        "ssm:GetParameter*"
      ],
      Effect = "Allow"
      Resource = [
        "arn:aws:ssm:*:${local.account_id}:parameter/symops.com/${local.function_name}/*"
      ]
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}
