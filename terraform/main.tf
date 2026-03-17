terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


resource "aws_cloudwatch_log_group" "services" {
  for_each          = toset(["app-service", "auth-service", "api-service"]) // these simulate multiple services running on multiple servers
  name              = "/cardioone/${each.key}"
  retention_in_days = 30 // logs are kept for 30 days then deleted automatically
}


resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  for_each       = toset(["app-service", "auth-service", "api-service"])
  name           = "ErrorFilter-${each.key}"
  pattern        = "?ERROR ?CRITICAL ?Exception"
  log_group_name = "/cardioone/${each.key}"

  metric_transformation {
    name      = "ErrorCount-${each.key}"
    namespace = "CardioOne/LogMetrics"
    value     = "1"
  }

  depends_on = [aws_cloudwatch_log_group.services]
}


resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  for_each            = toset(["app-service", "auth-service", "api-service"])
  alarm_name          = "HighErrorRate-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCount-${each.key}"
  namespace           = "CardioOne/LogMetrics"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "Alert: High error rate detected in ${each.key}"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]

  depends_on = [aws_cloudwatch_log_metric_filter.error_filter]
}



resource "aws_sns_topic" "alerts" {
  name = "cardioone-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_alert
}