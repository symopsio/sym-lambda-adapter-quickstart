# Sym Lambda SDK Example
This example contains a module that provisions an AWS Lambda that can be invoked from a Sym hook.

# Setup Instructions
## Net New Setup
If this is the first time you have applied Terraform to create Sym resources, you can apply this repo directly after filling in the following TODOs:
- [module/lambda/function/handler.py](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/modules/lambda/function/handler.py#L15)
  - To make a real API request, your Okta domain must be filled in on line 15.
  - If you do not fill in the domain, then an example ID will be returned.
- The [API_KEY SSM Parameter](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/modules/lambda/main.tf#L73) value must be updated with your Okta API Key
  - The SSM Parameter name is defined in [main.tf](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/main.tf#L14)
- [terraform.tfvars](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/terraform.tfvars)
  - Your Slack Workspace ID must be filled in
  - Your sym_org_slug must be filled in
- [lambda-sdk-impl.py](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/lambda-sdk-impl.py)
  - The Lambda ARN must match the output ARN of `module.lambda_handler`
  - The `service_id` parameter in `persist_user_identity` must be updated to your Okta domain (as displayed when running `symflow services list`)

## Adding to an Existing Setup
If you already have Sym resources (e.g. from another Quickstart), you can lift the relevant pieces from this repo:
- `module/lambda`: This module can be copied directly into your Terraform.
  - Declare the module in your `main.tf` with your desired `function_name` and `api_key_path`
  - See: [main.tf](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/main.tf#L10)
- [module/lambda/function/handler.py](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/modules/lambda/function/handler.py#L15)
  - Fill in your Okta domain on line 15 of the Lambda function.
- Declare a `lambda_connector` module
  - See: [flow.tf: module.lambda_connector](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/flow.tf#L2)
- Declare a `sym_integration.lambda_context`
  - See: [flow.tf: resource.sym_integration.lambda_context](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/flow.tf#L13)
- Add the `sym_integration.lambda_context.id` to your `sym_environment` integrations block as `aws_lambda_id`
  - See: [main.tf: resource.sym_environment.main](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/main.tf#L74)
- Add a hook to your `sym_flow`'s `impl.py`
  - Add the import: `from sym.sdk.integrations import aws_lambda`
  - Add the import: `from sym.sdk.utils.user import persist_user_identity`
  - Invoke your lambda with [`aws_lambda.invoke(...)`](https://sdk.docs.symops.com/doc/sym.sdk.integrations.aws_lambda.invoke.html)
  - Persist user identities with [`persist_user_identity(...)`](https://sdk.docs.symops.com/doc/sym.sdk.utils.user.persist_user_identity.html)
  - See: [lambda-sdk-impl.py: on_request](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/lambda-sdk-impl.py#L19) 

# Important pieces of note
- `module/lambda`: Is a stand-alone module that creates an AWS Lambda Function with access to SSM and Cloudwatch
- `sym_environment.integrations`: Your `sym_environment` resource must contain a `aws_lambda_id` in order to invoke your lambda from a hook
  - See: [main.tf: resource.sym_environment.main](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/main.tf#L74)
- `lambda_connector`: This module is required for the Sym Runtime to be able to invoke your lambda
  - See: [flow.tf: module.lambda_connector](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/flow.tf#L2)
  - See: [flow.tf: resource.sym_integration.lambda_context](https://github.com/symopsio/sym-lambda-adapter-quickstart/blob/leslie/lambda-sdk-example/flow.tf#L13)
