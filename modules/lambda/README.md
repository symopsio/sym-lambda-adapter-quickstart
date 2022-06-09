# Lambda Module
This module uses Terraform to package the AWS Lambda function defined in the `function` directory.

## Module Structure
### `function`
This directory contains the Python files defining the AWS Lambda. `handler.py` will parse events sent by the Sym Runtime
and make API calls to an API URL you configure.
