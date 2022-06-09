# Sym Lambda SDK Example
This example contains a module that provisions an AWS Lambda that can be invoked from a Sym hook.

# Setup Instructions
To apply this terraform, there are several TODOs to fill in:
- [module/lambda/function/handler.py](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/modules/lambda/function/handler.py#L15)
  - To make a request, your Okta domain must be filled in on line 15 
- The [API_KEY SSM Parameter](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/modules/lambda/main.tf#L73) value must be updated with your Okta API Key
- [terraform.tfvars](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/terraform.tfvars)
  - Your Slack Workspace ID must be filled in
  - Your sym_org_slug must be filled in
- [lambda-sdk-impl.py](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/lambda-sdk-impl.py)
  - The Lambda ARN must match the output ARN of `module.lambda_handler`
  - The `service_id` parameter in `persist_user_identity` must be updated to your Okta domain (as displayed when running `symflow services list`)

# Important pieces of note
- `module/lambda`: Is a stand-alone module that creates an AWS Lambda Function with access to SSM and Cloudwatch
- `sym_environment.integrations`: Your `sym_environment` resource must contain a `aws_lambda_id` in order to invoke your lambda from a hook
  - See: [main.tf: resource.sym_environment.main](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/main.tf#L74)
- `lambda_connector`: This module is required for the Sym Runtime to be able to invoke your lambda
  - See: [flow.tf: module.lambda_connector](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/flow.tf#L2)
  - See: [flow.tf: resource.sym_integration.lambda_context](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/flow.tf#L13)
