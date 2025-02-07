# terraform_python_project

This project sets up an AWS infrastructure using Terraform and Python to schedule tasks via an API, process messages from an SQS queue, and handle DynamoDB events.

## Project Structure

- **api/**: Contains the API code to schedule tasks.
  - **main.py**: The main application file for the API.
  - **requirements.txt**: Python dependencies for the API.

- **lambdas/**: Contains Lambda functions for processing tasks.
  - **execute_sqs_message/**: Lambda function to process SQS messages.
    - **main.py**: The main application file for the SQS message processing.
    - **requirements.txt**: Python dependencies for the execute SQS message Lambda function.
  - **rescheduler/**: Lambda function to handle DynamoDB REMOVE events.
    - **main.py**: The main application file for the Rescheduler Lambda function.
    - **requirements.txt**: Python dependencies for the Rescheduler Lambda function.

- **main.tf**: Terraform configuration for AWS resources.
- **variables.tf**: Input variables for the Terraform configuration.
- **outputs.tf**: Outputs of the Terraform configuration.
- **provider.tf**: AWS provider configuration for Terraform.

## Setup Instructions

1. **Install Dependencies**: Navigate to the `api`, `lambdas/execute_sqs_message`, and `lambdas/rescheduler` directories and run:
   ```
   pip install -r requirements.txt
   ```

2. **Deploy Infrastructure**: Use Terraform to deploy the infrastructure:
   ```
   terraform init
   terraform apply
   ```

3. **Usage**: 
   - Use the API endpoint exposed by API Gateway to schedule tasks by sending a POST request with `taskId` and `timeToExpire` parameters.
   - The Lambda functions will handle the processing of tasks based on the specified logic.

## License

This project is licensed under the MIT License.