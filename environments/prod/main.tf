provider "aws" {
  region = var.aws_region
}

provider "sym" {
  org = var.sym_org_slug
}

# A Sym Runtime that executes your Flows.
module "sym_runtime" {
  source = "../../modules/sym-runtime"

  error_channel      = var.error_channel
  runtime_name       = var.runtime_name
  slack_workspace_id = var.slack_workspace_id
  sym_account_ids    = var.sym_account_ids
  tags               = var.tags
}

locals {
  lambda_function_name = format("sym-adapter-%s", module.sym_runtime.environment.name)
}

# Adapter Lambda function
module "adapter_lambda" {
  source = "../../modules/adapter-lambda"

  function_name = local.lambda_function_name
  api_url       = var.api_url
  tags          = var.tags
}

# A Flow that uses the API Lambda
module "api_flow" {
  source = "../../modules/api-flow"

  flow_vars        = var.flow_vars
  lambda_arn       = module.adapter_lambda.lambda_arn
  runtime_settings = module.sym_runtime.runtime_settings
  sym_environment  = module.sym_runtime.environment
  targets          = var.api_targets
  tags             = var.tags
}
