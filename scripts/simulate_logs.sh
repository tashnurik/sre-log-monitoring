#!/bin/bash

# Log Simulator
# This script simulates logs from multiple services
# and sends them to AWS CloudWatch

LOG_GROUP_PREFIX="/cardioone"
SERVICES=("app-service" "auth-service" "api-service")
REGION="us-east-1"

echo "🚀 Starting Log Simulator..."

# Function to send a log event to CloudWatch
send_log() {
  local service=$1
  local message=$2
  local log_group="${LOG_GROUP_PREFIX}/${service}"
  local log_stream="simulation-$(date +%Y-%m-%d)"
  local timestamp=$(($(date +%s%N)/1000000))

  # Create log stream if it doesn't exist
  aws logs create-log-stream \
    --log-group-name "$log_group" \
    --log-stream-name "$log_stream" \
    --region $REGION 2>/dev/null

  # Send log event
  aws logs put-log-events \
    --log-group-name "$log_group" \
    --log-stream-name "$log_stream" \
    --log-events timestamp=$timestamp,message="$message" \
    --region $REGION 2>/dev/null

  echo "[$service] $message"
}

# Simulate normal logs first
echo ""
echo "📝 Sending normal logs..."
for service in "${SERVICES[@]}"; do
  send_log $service "INFO: Service started successfully"
  send_log $service "INFO: Health check passed"
  send_log $service "INFO: Processing request completed"
done

sleep 2

# Simulate error logs to trigger alarms
echo ""
echo "⚠️  Sending ERROR logs to trigger alarms..."
for service in "${SERVICES[@]}"; do
  send_log $service "ERROR: Database connection failed"
  send_log $service "ERROR: Request timeout exceeded"
  send_log $service "CRITICAL: Service is unresponsive"
  send_log $service "ERROR: Failed to process patient data"
  send_log $service "CRITICAL: Memory threshold exceeded"
  send_log $service "Exception: NullPointerException in DataService"
done

echo ""
echo "✅ Log simulation complete!"
echo "⏳ Wait 1-2 minutes then check:"
echo "   - CloudWatch Alarms for state change to ALARM"
echo "   - Your email for alert notification"