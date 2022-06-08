module "lambda_connector" {
  source  = "terraform.symops.com/symopsio/lambda-connector/sym"
  version = ">= 1.0.0"

  environment       = var.environment
  lambda_arns       = [aws_lambda_function.this.arn]
  runtime_role_arns = [module.runtime_connector.settings["role_arn"]]
}

resource "sym_integration" "lambda_context" {
  type        = "permission_context"
  name        = "lambda-${var.environment}"
  external_id = module.lambda_connector[0].settings.account_id

  settings = module.lambda_connector[0].settings
}

resource "aws_iam_role" "iam_for_lambda" {
  count = local.lambda_flow_count

  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
    "Action": "sts:AssumeRole",
    "Principal": {
    "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
}
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic_lambda" {
  count = local.lambda_flow_count
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda[0].name
}

resource "aws_lambda_function" "this" {
  filename      = "lambda_function.zip"
  function_name = "${var.environment}-lambda"
  role          = aws_iam_role.iam_for_lambda[0].arn
  handler       = "lambda_function.lambda_handler"

  # Note: to use you must zip the lambda_function directory
  source_code_hash = filebase64sha256("lambda_function.zip")

  runtime = "python3.9"
}
