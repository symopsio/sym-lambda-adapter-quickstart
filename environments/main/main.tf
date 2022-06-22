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

# A Flow that uses the [AWS Lambda](https://docs.symops.com/docs/aws-lambda)
# strategy to call an AWS Lambda for custom escalation and de-escalation logic.
module "adapter_flow" {
  source = "../../modules/adapter-flow"

  flow_vars        = var.flow_vars
  lambda_vars      = var.lambda_vars
  runtime_settings = module.sym_runtime.runtime_settings
  sym_environment  = module.sym_runtime.environment
  targets          = var.flow_targets
  tags             = var.tags
}
