def lambda_handler(event, context):
    print(event)

    # Simple way to call this lambda from the SDK as a test
    if event.get("action") == "sdk_invoke":
        return {"body": {"message": "hi"}, "errors": []}

    event_type = event["event"]["type"]
    reason = event["fields"].get("reason", "no question")

    answer = magic_answer()

    if event_type == "escalate":
        return {
            "body": {
                "message": f"The answer to your question `{reason}` is:\n\n `{answer}`",
                "event_type": event_type,
            },
            "errors": [],
        }
    elif event_type == "deescalate":
        return {
            "body": {"message": "ok bye!", "event_type": event_type},
            "errors": [],
        }
    else:
        return {"body": {"event": event}, "errors": [f"The event {event_type} is not handled!"]}


def magic_answer():
    import random

    answers = [
        "It is certain.",
        "It is decidedly so.",
        "Without a doubt.",
        "Yes definitely.",
        "You may rely on it.",
        "As I see it, yes.",
        "Most likely.",
        "Outlook good.",
        "Yes.",
        "Signs point to yes.",
        "Reply hazy, try again.",
        "Ask again later.",
        "Better not tell you now.",
        "Cannot predict now.",
        "Concentrate and ask again.",
        "Don't count on it.",
        "My reply is no.",
        "My sources say no.",
        "Outlook not so good.",
        "Very doubtful.",
    ]
    return answers[random.randint(0, 19)]
