locals {
  # The path to the Lambda Function source code
  lambda_root = "${path.module}/handler"
  build_root  = "${local.lambda_root}/build"
}

# This has resource will pip install our Python dependencies into the
# handler/build folder when requirements.txt changes
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${local.lambda_root}/requirements.txt -t ${local.build_root}/layer/python --upgrade"
  }

  triggers = {
    # If any of the following files change, then pip install will be triggered
    dependencies_versions = filemd5("${local.lambda_root}/requirements.txt")
  }
}

# Copy the python source code to a handler directory so we can archive it independently
resource "null_resource" "copy_handler" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.build_root}/handler && cp ${local.lambda_root}/*.py ${local.build_root}/handler"
  }

  triggers = {
    for f in fileset(local.lambda_root, "*.py") : f => filemd5("${local.lambda_root}/${f}")
  }
}

# This resource generates an MD5 hash of the zip file contents.
# This ensures that the aws_lambda_function will be updated when we generate a new zip file.
resource "random_uuid" "layer_hash" {
  keepers = {
    requirements = filemd5("${local.lambda_root}/requirements.txt")
  }
}

resource "random_uuid" "handler_hash" {
  keepers = {
    for filename in fileset(local.lambda_root, "*.py") :
    filename => filemd5("${local.lambda_root}/${filename}")
  }
}

# This data resource will generate a new archive automatically whenever
# requirements.txt is updated.
data "archive_file" "layer" {
  depends_on = [null_resource.install_dependencies]
  excludes = [
    "__pycache__",
    "venv",
  ]

  source_dir  = "${local.build_root}/layer"
  output_path = "${local.lambda_root}/dist/layer-${random_uuid.layer_hash.result}.zip"
  type        = "zip"
}

# This data resource will generate a new archive automatically whenever
# the handler code is updated.
data "archive_file" "handler" {
  depends_on = [null_resource.copy_handler]

  source_dir  = "${local.build_root}/handler"
  output_path = "${local.lambda_root}/dist/handler-${random_uuid.handler_hash.result}.zip"
  type        = "zip"
}
