from sym.sdk.annotations import hook, reducer
from sym.sdk.integrations import slack, aws_lambda
from sym.sdk.utils.user import persist_user_identity

# Reducers fill in the blanks that your workflow needs in order to run.
@reducer
def get_approvers(evt):
    """
    Post to shared channel to ask for access approval, allowing
    self-approval
    """
    fvars = evt.flow.vars

    # Request approval in channel
    return slack.channel(fvars["request_channel"], allow_self=True)


# Hooks let you change the control flow of your workflow.
@hook
def on_request(evt):
    """
    Get the okta ID and save the identity
    """
    lambda_arn = "arn:aws:lambda:us-east-1:838419636750:function:get-okta-id"
    response = aws_lambda.invoke(lambda_arn, {"email": evt.user.email})
    okta_id = response["okta_id"]
    persist_user_identity(email=evt.user.email, service="okta", service_id="okta-domain", user_id=okta_id)

    print(f"Successfully persisted Okta Identity {okta_id} for {evt.user.email}")
