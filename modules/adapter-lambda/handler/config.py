import os
from dataclasses import dataclass

import boto3


@dataclass
class Config:
    api_token: str
    api_url: str


def get_config() -> Config:
    """
    Loads configuration from environment and SSM
    """
    return Config(
        api_url=os.environ["API_URL"],
        api_token=get_api_token(),
    )


def get_api_token() -> str:
    """
    Check if the token is defined as an env var (for local testing)
    otherwise look up the value in Systems Manager Parameter Store.
    """
    if env_value := os.environ.get("API_KEY"):
        return env_value

    api_key_path = os.environ.get("API_KEY_PATH", "/symops.com/API_KEY")

    ssm = boto3.client("ssm")
    result = ssm.get_parameter(Name=api_key_path, WithDecryption=True)
    return result["Parameter"]["Value"]
