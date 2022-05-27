variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
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

variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python"
  type        = map(string)
  default     = {}
}

variable "api_url" {
  description = "The API URL your Lambda should hit"
  type        = string
}

variable "api_targets" {
  description = "List of API target IDs and Labels"
  type = list(object({
    id = string, label = string
  }))
}

variable "runtime_name" {
  description = "Name to assign to the Sym Runtime and its associated resources."
  type        = string
  default     = "prod"
}

variable "slack_workspace_id" {
  description = "The Slack Workspace ID to use for your Slack integration"
  type        = string
}

variable "sym_account_ids" {
  description = "List of account ids that can assume the Sym runtime role. By default, only Sym production accounts can assume the runtime role."
  type        = list(string)
  default     = ["803477428605"]
}

variable "sym_org_slug" {
  description = "Sym org slug for your org"
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
