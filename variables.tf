variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "lambda_execution_role" {
  description = "The IAM role for Lambda execution"
  type        = string
}

variable "sqs_queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "lambda_timeout" {
  description = "The timeout for the Lambda functions in seconds"
  type        = number
  default     = 30
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}