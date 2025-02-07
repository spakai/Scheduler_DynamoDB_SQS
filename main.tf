resource "aws_lambda_function" "api_lambda" {
  function_name = "schedule_task_api"
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("api.zip")
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

 
resource "aws_api_gateway_rest_api" "api" {
  name        = "TaskSchedulerAPI"
  description = "API to schedule tasks"
}

resource "aws_api_gateway_resource" "schedule_task" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "schedule"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.schedule_task.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.schedule_task.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_sqs_queue" "task_queue" {
  name = "taskQueue"
}

resource "aws_dynamodb_table" "tasks_table" {
  name         = "Tasks"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "taskId"
    type = "S"
  }
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

resource "aws_lambda_function" "execute_sqs_message" {
  function_name = "execute_sqs_message"
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("execute_sqs_message.zip")
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.task_queue.arn
  function_name    = aws_lambda_function.execute_sqs_message.arn
  batch_size       = 10
  enabled          = true
}

resource "aws_lambda_function" "rescheduler" {
  function_name = "rescheduler"
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("rescheduler.zip")
}

resource "aws_dynamodb_table_item" "task_item" {
  table_name = aws_dynamodb_table.tasks_table.name
  hash_key   = "taskId"
  item       = jsonencode({
    taskId      = "exampleTaskId"
    ttl         = timeadd(timestamp(), "48h")
  })
}

