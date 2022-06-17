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

resource "sym_flow" "lambda-sdk-example" {
  name  = "lambda-sdk-example"
  label = "AWS Lambda SDK Example"

  template       = "sym:template:approval:1.0.0"
  implementation = "${path.module}/lambda-sdk-impl.py"
  environment_id = sym_environment.main.id

  vars = merge(
    var.flow_variables,
    {
      lambda_arn = module.lambda_handler.lambda_arn
    }
  )

  params = {
    # prompt_fields_json defines custom form fields for the Slack modal that
    # requesters fill out to make their requests.
    prompt_fields_json = jsonencode([
      {
        name     = "reason"
        label    = "Why do you need access?"
        type     = "string"
        required = true
      }
    ])
  }
}
