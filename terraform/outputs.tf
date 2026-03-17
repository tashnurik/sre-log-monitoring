output "log_group_names" {
  description = "CloudWatch Log Group names for each service"
  value       = [for k, v in aws_cloudwatch_log_group.services : v.name]
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "CloudWatch Alarm names for each service"
  value       = [for k, v in aws_cloudwatch_metric_alarm.error_alarm : v.alarm_name]
}