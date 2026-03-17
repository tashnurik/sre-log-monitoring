variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "email_alert" {
  description = "Email address to receive alerts"
  type        = string
}

variable "error_threshold" {
  description = "Number of errors before alarm triggers"
  type        = number
  default     = 5
}

variable "alarm_period" {
  description = "Time window in seconds to count errors"
  type        = number
  default     = 300
}