# The AWS IAM Resources that enable Sym to invoke your Lambda functions.
module "lambda_connector" {
  source  = "terraform.symops.com/symopsio/lambda-connector/sym"
  version = ">= 1.12.0"

  environment       = var.environment_name
  lambda_arns       = [module.lambda_handler.lambda_arn]
  runtime_role_arns = [sym_integration.runtime_context.settings.role_arn]

  tags = var.tags
}

# The Integration your Strategy uses to invoke Lambdas.
resource "sym_integration" "lambda_context" {
  type = "permission_context"
  name = "lambda-context-${var.environment_name}"

  external_id = module.lambda_connector.settings.account_id
  settings    = module.lambda_connector.settings
}

# A target that your API grants access to
resource "sym_target" "admin_role" {
  type = "aws_lambda_function"

  name  = "admin-role"
  label = "Admin Role"

  settings = {
    # The Lambda that is invoked when a request is made for this target
    arn = module.lambda_handler.lambda_arn
  }
}
# A target that your API grants access to
resource "sym_target" "read_role" {
  type = "aws_lambda_function"

  name  = "read-role"
  label = "Read Only Role"

  settings = {
    # The Lambda that is invoked when a request is made for this target
    arn = module.lambda_handler.lambda_arn
  }
}

# The Strategy your Flow uses to manage Target AWS Lambda functions.
resource "sym_strategy" "this" {
  type = "aws_lambda"

  name           = "lambda-strategy"
  integration_id = sym_integration.lambda_context.id
  targets        = [sym_target.admin_role.id, sym_target.read_role.id]
}

# The Flow that grants users access by invoking your Lambda
resource "sym_flow" "this" {
  name  = "lambda-strategy"
  label = "Sym AWS Lambda Quickstart"

  template = "sym:template:approval:1.0.0"

  implementation = "${path.module}/impl.py"

  environment_id = sym_environment.main.id

  vars = var.flow_variables

  params = {
    strategy_id = sym_strategy.this.id

    prompt_fields_json = jsonencode(
      [
        {
          name     = "reason"
          type     = "string"
          required = true
        }
      ]
    )
  }
}
