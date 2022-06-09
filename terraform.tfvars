# Slack Channel to send integration or runtime errors to
error_channel = "#sym-errors"

flow_variables = {
  # Slack Channel where requests should go
  request_channel = "#sym-access"
}

# TODO: Fill in your Slack Workspace ID
# Slack Workspace where Sym is installed
slack_workspace_id = "T0106DCL4BB"

# TODO: Fill in your organization slug
# Your org slug will be provided to you by your Sym onboarding team
sym_org_slug = "sym"

# Optionally add more tags to the AWS resources we create
tags = {
  "vendor" = "symops.com"
}
