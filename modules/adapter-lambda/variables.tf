variable "function_name" {
  description = "Name of the Lambda function to create"
  type        = string
  default     = "sym-adapter"
}

variable "api_url" {
  description = "The API URL your Lambda should hit"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
