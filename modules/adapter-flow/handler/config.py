import os
from dataclasses import dataclass

import boto3


@dataclass
class Config:
    function_name: str


def get_config() -> Config:
    """
    Loads configuration from environment and SSM.

    We use function_name as an example, but anything from your Terraform lambda_vars should be
    accessible as configuration here.

    AWS_LAMBDA_FUNCTION_NAME is one of the default environment variable provided by the Lambda runtime:
    https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html#configuration-envvars-runtime
    """
    return Config(function_name=os.environ["AWS_LAMBDA_FUNCTION_NAME"])


def get_ssm_parameter(parameter_name: str) -> str:
    """
    Helper method to read secrets from AWS SSM if appropriate. Looks in environment variables first
    to facilitate local testing.
    """
    if env_value := os.environ.get(parameter_name):
        return env_value

    function_name = os.environ["AWS_LAMBDA_FUNCTION_NAME"]
    api_key_path = f"/symops.com/{function_name}/{parameter_name}"

    ssm = boto3.client("ssm")
    result = ssm.get_parameter(Name=api_key_path, WithDecryption=True)
    return result["Parameter"]["Value"]
