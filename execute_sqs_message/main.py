def lambda_handler(event, context):
    import boto3
    import json
    from datetime import datetime, timedelta

    sqs = boto3.client('sqs')
    queue_url = 'YOUR_SQS_QUEUE_URL'  # Replace with your SQS queue URL

    for record in event['Records']:
        message_body = json.loads(record['body'])
        task_id = message_body['taskId']
        time_to_expire = message_body['timeToExpire']
        current_time = datetime.utcnow()

        # Calculate the expiration time
        expiration_time = current_time + timedelta(seconds=time_to_expire)

        if expiration_time <= current_time + timedelta(days=2):
            # Push to DynamoDB with TTL
            dynamodb = boto3.resource('dynamodb')
            table = dynamodb.Table('YOUR_DYNAMODB_TABLE_NAME')  # Replace with your DynamoDB table name
            ttl = int((expiration_time - timedelta(days=2)).timestamp())
            table.put_item(
                Item={
                    'taskId': task_id,
                    'timeToExpire': time_to_expire,
                    'TTL': ttl
                }
            )
        else:
            # Short-term task, check if it should run
            if current_time >= expiration_time:
                # Execute the task
                print(f'Executing task: {task_id}')
                # Add your task execution logic here
                # Delete the message from SQS
                sqs.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=record['receiptHandle']
                )
            else:
                # Hide the message again
                visibility_timeout = 43200  # 12 hours in seconds
                sqs.change_message_visibility(
                    QueueUrl=queue_url,
                    ReceiptHandle=record['receiptHandle'],
                    VisibilityTimeout=visibility_timeout
                )