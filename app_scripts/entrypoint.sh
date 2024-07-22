#!/bin/bash

# ./entrypoint.sh

# Function to get Redis IP from ECS task metadata
get_redis_ip() {
    TASK_METADATA=$(curl -s "${ECS_CONTAINER_METADATA_URI_V4}/task")
    REDIS_CONTAINER=$(echo $TASK_METADATA | jq -r '.Containers[] | select(.Name == "redis")')
    REDIS_IP=$(echo $REDIS_CONTAINER | jq -r '.Networks[0].IPv4Addresses[0]')
    echo $REDIS_IP
}

# Get Redis IP (it should be immediately available as it's in the same task)
REDIS_IP=$(get_redis_ip)

if [ -z "$REDIS_IP" ]; then
    echo "Failed to get Redis IP"
    exit 1
fi

echo "Redis IP found: $REDIS_IP"

# Set REDIS_URL environment variable
export REDIS_URL="redis://$REDIS_IP:6379"

# Start the main application
exec ruby /app/counter_app.rb