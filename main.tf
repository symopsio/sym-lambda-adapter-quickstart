provider "aws" {
  region = "us-east-1"
}

provider "sym" {
  org = var.sym_org_slug
}

# Creates a Lambda that is invoked by the Sym Runtime on escalate/de-escalate
module "lambda_handler" {
  source = "./modules/lambda"

  function_name = "get-okta-id"
  api_key_path = "/symops.com/get-okta-id/API_KEY"
  tags          = var.tags
}

# Creates an AWS IAM Role that the Sym Runtime can use for execution
# Allow the runtime to assume roles in the /sym/ path in your AWS Account
module "runtime_connector" {
  source  = "terraform.symops.com/symopsio/runtime-connector/sym"
  version = ">= 1.1.0"

  addons          = ["aws/secretsmgr"]
  environment     = var.environment_name
  sym_account_ids = var.sym_account_ids

  tags = var.tags
}

# An integration with Slack that allows Sym to connect with your Slack Workspace
resource "sym_integration" "slack" {
  type = "slack"
  name = "slack-${var.environment_name}"

  external_id = var.slack_workspace_id
}

# Send errors during Flow execution to a shared logging channel
resource "sym_error_logger" "slack" {
  integration_id = sym_integration.slack.id
  destination    = var.error_channel
}

# An Integration that tells the Sym Runtime resource which AWS Role to assume
# (The AWS Role created by the runtime_connector module)
resource "sym_integration" "runtime_context" {
  type = "permission_context"
  name = "runtime-${var.environment_name}"

  external_id = module.runtime_connector.settings.account_id
  settings    = module.runtime_connector.settings
}

# Declares a Sym Runtime where workflows can execute
# The runtime will assume the role identified by the `runtime_context` Integration.
resource "sym_runtime" "this" {
  name       = var.environment_name
  context_id = sym_integration.runtime_context.id
}

# A sym environment collects together a group of integrations to simplify
# Flow configuration.
resource "sym_environment" "main" {
  name            = var.environment_name
  runtime_id      = sym_runtime.this.id
  error_logger_id = sym_error_logger.slack.id

  integrations = {
    # Enables sym.sdk.integrations.slack SDK methods
    slack_id = sym_integration.slack.id

    # Enables sym.sdk.integration.aws_lambda SDK methods
    aws_lambda_id = sym_integration.lambda_context.id
  }
}
