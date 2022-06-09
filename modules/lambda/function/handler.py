import boto3
import json
import logging
import os
import requests
import sys

logging.getLogger().setLevel(logging.INFO)


def handle(event: dict, context) -> dict:
    """
    The entry point for a Lambda function that calls an external API to escalate and de-escalate users
    This method will be invoked by the Sym Runtime on escalate and de-escalate.

    For more details on the event object format, refer to our reporting docs:
    https://docs.symops.com/docs/reporting
    """
    logging.info("Got event:")
    logging.info(json.dumps(event))

    try:
        # Parse the event sent from the Sym Runtime
        requester = event["run"]["actors"]["request"]["username"]
        target = event["fields"]["target"]["name"]

        # Call different APIs depending on if the action is escalate or deescalate
        event_type = event["event"]["type"]

        if event_type == "escalate":
            escalate(requester, target)
        elif event_type == "deescalate":
            deescalate(requester, target)

        # This response object can be used in hooks you implement for your Sym Flow!
        return {"body": {}, "errors": []}
    except Exception as e:
        # Any errors reported here will be sent to the error channel you configure for your Sym Environment
        return {"body": {}, "errors": [str(e).rstrip()]}


def escalate(user, target):
    logging.info(f"Escalating user {user} to target {target}")

    # TODO: Set the API you want to hit to escalate the user
    api_url = ""

    # Set the Authorization header to the Bearer token configured in SSM/environment
    headers = {"Authorization": f"Bearer {get_api_token()}"}

    # TODO: Modify the JSON Body based on your API requirements
    data = {"user": user, "target": target}

    if api_url:
        # POST data to api_url
        resp = requests.post(api_url, json=data, headers=headers)

        # Raise an error if we did not get a 2xx response
        if not resp.ok:
            raise RuntimeError(
                f"API failed with status code: {resp.status_code} and message: {resp.text}"
            )
    else:
        logging.info("No API URL set! This is where the lambda would call POST escalate a user.")
        logging.info(f"POST body: {data}")


def deescalate(user, target):
    logging.info(f"De-escalating user {user} from target {target}")

    # TODO: Set the API you want to hit to de-escalate the user
    api_url = ""

    if api_url:
        # Set the Authorization header to the Bearer token configured in SSM/environment
        headers = {"Authorization": f"Bearer {get_api_token()}"}

        # Call DELETE api_url
        resp = requests.delete(api_url, headers=headers)

        # Raise an error if we did not get a 2xx response
        if resp.ok:
            raise RuntimeError(
                f"API failed with status code: {resp.status_code} and message: {resp.text}"
            )
    else:
        logging.info("No API URL set! This is where the lambda would call DELETE to de-escalate a user.")


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


def load_event():
    """Load a JSON objects from stdin, to help testing locally."""
    if not sys.stdin.isatty():
        lines = sys.stdin.readlines()
        data = " ".join(lines)
        return json.loads(data)
    raise RuntimeError("Please supply a json payload via stdin")


if __name__ == "__main__":
    """This main method is only used for local testing!"""
    event = load_event()
    result = handle(event, {})
    logging.info(result)
