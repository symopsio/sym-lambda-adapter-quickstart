variable "environment_name" {
  description = "The name of the Sym environment these resources belong to."
  type        = string
  default     = "main"
}

variable "error_channel" {
  description = "The error channel to use to surface Sym errors."
  type        = string
  default     = "#sym-errors"
  validation {
    condition     = can(regex("^#.+", var.error_channel))
    error_message = "Error channel should start with #."
  }
}

variable "flow_variables" {
  description = "Configuration values for the Flow, available in its implementation for hooks and reducers."
  type        = map(string)
  default     = {}
}

variable "slack_workspace_id" {
  description = "The Slack Workspace ID to use for your Slack integration."
  type        = string
}

variable "sym_account_ids" {
  description = "List of account ids that can assume the Sym runtime role. By default, only Sym production accounts can assume the runtime role."
  type        = list(string)
  default     = ["803477428605"]
}

variable "sym_org_slug" {
  description = "Uniquely identifying slug for your organization in Sym."
  type        = string
  validation {
    condition     = can(regex("[[:alnum:]]+", var.sym_org_slug))
    error_message = "The org slug must be alphanumeric."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
