variable "flow_name" {
  type        = string
  description = "Name for the flow, used to create identifiers and for shortcuts"
  default     = "api"
}

variable "flow_label" {
  type        = string
  description = "Display name for the flow"
  default     = "API"
}

variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python."
  type        = map(string)
}

variable "lambda_arn" {
  description = "The target AWS Lambda ARN that the flow will invoke"
  type        = string
}

variable "runtime_settings" {
  description = "Runtime connector settings"
  type        = object({ role_arn = string })
}

variable "sym_environment" {
  description = "Sym Environment for this Flow."
  type        = object({ id = string, name = string })
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "targets" {
  description = "List of API IDs and Labels"
  type = list(object({
    id = string, label = string
  }))
}
