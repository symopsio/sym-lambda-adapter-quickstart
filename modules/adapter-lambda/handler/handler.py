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
    Hit the API with your credentials
    """
    # escalate or deescalate
    event_type = event["event"]["type"]

    # find the target id based on the request target
    target_id = resolve_target_id(event)

    # get config data from AWS SSM
    config = get_config()

    # construct an API url using the event type (?)
    api_url = f"{config.api_url}/{event_type}"

    headers = {"API_TOKEN": config.api_token}
    data = {"user": username, "target": target_id}
    resp = requests.post(api_url, data=data, headers=headers)
    if resp.status_code != 200:
        raise RuntimeError(
            f"API failed with status code: {resp.status_code} and message: {resp.text}"
        )
    return {"text": resp.text}


def resolve_target_id(event: dict) -> str:
    """
    Get the target id from the target name. The name that comes in from sym is the flow name plus the
    target id.
    """
    full_name = event["fields"]["target"]["name"]
    return full_name.split("-")[-1]


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
