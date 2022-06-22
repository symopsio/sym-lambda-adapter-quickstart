variable "flow_name" {
  type        = string
  description = "Name for the flow, used to create identifiers and for shortcuts"
  default     = "adapter"
}

variable "flow_label" {
  type        = string
  description = "Display name for the flow"
  default     = "Adapter"
}

variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python."
  type        = map(string)
}

variable "lambda_vars" {
  description = "Key-value pairs that should be supplied to your lambda as environment variables"
  type        = map(string)
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
  description = "List of IDs and Labels to pass to the lambda adapter"
  type = list(object({
    id = string, label = string
  }))
}
