output "api_endpoint" {
  value = aws_api_gateway_deployment.api_gateway_deployment.invoke_url
}

output "execute_sqs_lambda_arn" {
  value = aws_lambda_function.execute_sqs_message.arn
}

output "rescheduler_lambda_arn" {
  value = aws_lambda_function.rescheduler.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.task_queue.url
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tasks_table.name
}