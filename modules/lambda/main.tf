locals {
  # The path to the Lambda Function source code
  lambda_root = "${path.module}/function"
}

# This has resource will pip install our Python dependencies into the function/ folder
# when requirements.txt or handler.py is updated.
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${local.lambda_root}/requirements.txt -t ${local.lambda_root}/build --upgrade"
  }
  provisioner "local-exec" {
    command = "cp ${local.lambda_root}/handler.py ${local.lambda_root}/build"
  }

  triggers = {
    # If any of the following files change, then pip install will be triggered
    dependencies_versions = filemd5("${local.lambda_root}/requirements.txt")
    source_versions       = filemd5("${local.lambda_root}/handler.py")
  }
}

# This resource generates an MD5 hash of the zip file contents.
# This ensures that the aws_lambda_function will be updated when we generate a new zip file.
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_root, "*.py"),
      fileset(local.lambda_root, "requirements.txt")
    ):
    filename => filemd5("${local.lambda_root}/${filename}")
  }
}

# This data resource will generate a new `lambda_function.zip` archive automatically whenever
# requirements.txt or handler.py is updated.
data "archive_file" "lambda_source" {
  depends_on = [null_resource.install_dependencies]
  excludes = [
    "__pycache__",
    "venv",
  ]

  source_dir  = "${local.lambda_root}/build"
  output_path = "${local.lambda_root}/dist/lambda_function-${random_uuid.lambda_src_hash.result}.zip"
  type        = "zip"
}


# This resource will create a AWS Lambda Function with the zip file generated from the function/ folder.
resource "aws_lambda_function" "sym_quickstart_lambda" {
  function_name = var.function_name

  filename = data.archive_file.lambda_source.output_path
  handler  = "handler.handle"
  runtime  = "python3.8"

  environment {
    variables = {
      "API_KEY_PATH" = var.api_key_path
    }
  }

  role = aws_iam_role.lambda_execution_role.arn

  timeout = 3

  tags = var.tags
}


# The AWS SSM Parameter containing the Bearer Token to use in the Authorization header
# when calling the API to escalate/de-escalate.
resource "aws_ssm_parameter" "api_key" {
  name  = var.api_key_path
  type  = "SecureString"
  value = "CHANGEME"

  lifecycle {
    ignore_changes = [value, version]
  }
}
