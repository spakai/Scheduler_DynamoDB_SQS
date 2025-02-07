from flask import Flask, request, jsonify
import boto3
import os
import json
from datetime import datetime, timedelta

app = Flask(__name__)

# Initialize DynamoDB and SQS clients
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

# Environment variables for DynamoDB and SQS
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE')
SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL')

@app.route('/schedule', methods=['POST'])
def schedule_task():
    data = request.json
    task_id = data.get('taskId')
    time_to_expire = data.get('timeToExpire')

    if not task_id or not isinstance(time_to_expire, int):
        return jsonify({'error': 'Invalid input'}), 400

    if time_to_expire >= 172800:  # 48 hours in seconds
        # Push to DynamoDB with TTL
        ttl = int((datetime.utcnow() + timedelta(seconds=time_to_expire - 172800)).timestamp())
        dynamodb.Table(DYNAMODB_TABLE).put_item(
            Item={
                'taskId': task_id,
                'timeToExpire': time_to_expire,
                'TTL': ttl
            }
        )
        return jsonify({'message': 'Task scheduled in DynamoDB'}), 201
    else:
        # Push to SQS
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({'taskId': task_id, 'timeToExpire': time_to_expire}),
            DelaySeconds=0
        )
        return jsonify({'message': 'Task scheduled in SQS'}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)