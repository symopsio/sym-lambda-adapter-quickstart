variable "function_name" {
  description = "Name of the Lambda function to create"
  type        = string
  default     = "sym-lambda-quickstart-function"
}

variable "api_key_path" {
  description = "The name of the SSM Parameter containing your API Token"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
