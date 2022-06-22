import json
import sys

import requests
from devtools import debug

from config import get_config


def handle(event: dict, context) -> dict:
    """
    For more details on the event object format, refer to our reporting docs:
    https://docs.symops.com/docs/reporting
    """
    print("Got event:")
    print(json.dumps(event))

    try:
        username = resolve_user(event)
        update_user(username, event)
        return {"body": {}, "errors": []}
    except Exception as e:
        return {"body": {}, "errors": [str(e).rstrip()]}


def resolve_user(event: dict) -> str:
    """
    Placeholder in case you need to do additional modification of the incoming user name before
    supplying to your API
    """
    return event["run"]["actors"]["request"]["username"]


def update_user(username: str, event: dict):
    """
    Placeholder to update the user given a resolved username and input event.
    """
    # escalate or deescalate
    event_type = event["event"]["type"]

    # find the target name based on the request target
    target_name = event["fields"]["target"]["name"]

    # get config data from AWS SSM
    config = get_config()

    # Example API URL and placeholder API token
    # You can use the get_ssm_parameter helper method in
    # config.py to look up the parameter in Parameter Store.
    # e.g. my_token = config.get_ssm_parameter("ssm_parameter_name")
    api_url = "https://pastebin.com/api/api_post.php"
    headers = {"API_TOKEN": "my_token"}

    data = {"user": username, "target": target_name}
    resp = requests.post(api_url, data=data, headers=headers)
    if resp.status_code not in range(200, 299):
        raise RuntimeError(
            f"API failed with status code: {resp.status_code} and message: {resp.text}"
        )
    return {"text": resp.text}


def load_event():
    """Load json from stdin"""
    if not sys.stdin.isatty():
        lines = sys.stdin.readlines()
        data = " ".join(lines)
        return json.loads(data)
    raise RuntimeError("Please supply a json payload via stdin")


if __name__ == "__main__":
    event = load_event()
    result = handle(event, {})
    debug(result)
