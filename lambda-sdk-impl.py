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


@hook
def on_request(evt):
    """
    Before executing a request, get the okta ID of the requester and save their identity.
    """

    fvars = evt.flow.vars
    response = aws_lambda.invoke(fvars["lambda_arn"], {"email": evt.user.email})
    if okta_id := response["okta_id"]:
        # TODO: Update the service_id with your okta-domain
        #   This is the "External ID" displayed when running `symflow services list`
        persist_user_identity(email=evt.user.email, service="okta", service_id="okta-domain", user_id=okta_id)

        print(f"Successfully persisted Okta Identity {okta_id} for {evt.user.email}")
