import boto3
import logging
import os
import requests

logging.getLogger().setLevel(logging.INFO)


def handle(event: dict, context) -> dict:
    """
    The entry point for a Lambda function that calls the Okta API and returns the user ID
    """

    # TODO: Fill in your okta_domain
    okta_domain = ""

    # For testing purposes if you don't have an okta_domain at hand.
    if not okta_domain:
        return {"okta_id": "00ub0oNGTSWTBKOLGLNR"}

    # emails are first.last@domain.com
    email = event["email"]

    # okta user names are first.last
    okta_username = email.split("@")[0]

    # You could import the Okta Python SDK (https://github.com/okta/okta-sdk-python#usage-guide)
    # but that requires asyncio, so we will just call the API directly for this POC
    # Get User by Login: https://developer.okta.com/docs/reference/api/users/#get-user-with-login
    get_user_api = f"https://{okta_domain}/api/v1/users/{okta_username}"
    headers = {"Authorization": f"SSWS {get_api_token()}"}

    response = requests.get(get_user_api, headers=headers)

    if response.ok:
        return {"okta_id": response.json()["id"]}
    else:
        logging.error(f"Failed to retrieve Okta user. Received: {response.status_code}")
        logging.warning(response.json())
        return {"okta_id": None}


def get_api_token() -> str:
    """
    Check if the token is defined as an env var (for local testing)
    otherwise look up the value in Systems Manager Parameter Store.
    """
    if env_value := os.environ.get("API_KEY"):
        return env_value

    api_key_path = os.environ.get("API_KEY_PATH")
    ssm = boto3.client("ssm")
    result = ssm.get_parameter(Name=api_key_path, WithDecryption=True)
    return result["Parameter"]["Value"]
