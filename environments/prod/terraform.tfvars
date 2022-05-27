# Slack Channel to send integration or runtime errors to
error_channel = "#sym-errors"

flow_vars = {
  # Slack Channel where requests should go
  request_channel = "#sym-requests"

  # Optional safelist of users that can approve requests
  approvers = "foo@myco.com,bar@myco.com"
}

# API URL. Including this as an example of other configuration
# points you might want to supply to your Lambda function as environment
# variables
api_url = "https://pastebin.com/api/api_post.php"

# List of targets that users can request access to.
# Each item has a label and id.
api_targets = [
  {
    label = "My Label",
    id    = "my-id"
  }
]

# Slack Workspace where Sym is installed
slack_workspace_id = "CHANGEME"

# Your org slug will be provided to you by your Sym onboarding team
sym_org_slug = "CHANGEME"

# Optionally add more tags to the AWS resources we create
tags = {
  "vendor" = "symops.com"
}
