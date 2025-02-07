def lambda_handler(event, context):
    import boto3
    import json

    sqs = boto3.client('sqs')
    queue_url = 'YOUR_SQS_QUEUE_URL'  # Replace with your SQS queue URL

    for record in event['Records']:
        # Extract the necessary information from the DynamoDB event
        task_info = json.loads(record['dynamodb']['NewImage']['taskInfo']['S'])
        
        # Forward the task information to the SQS queue
        response = sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(task_info)
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Rescheduling completed successfully.')
    }