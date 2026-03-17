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



resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "CardioOne-Log-Monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "alarm"
        x      = 0
        y      = 0
        width  = 24
        height = 3
        properties = {
          title  = "Service Alarms Overview"
          alarms = [
            "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:HighErrorRate-app-service",
            "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:HighErrorRate-auth-service",
            "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:HighErrorRate-api-service"
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "Error Count - App Service"
          region  = var.aws_region
          metrics = [["CardioOne/LogMetrics", "ErrorCount-app-service"]]
          period  = 300
          stat    = "Sum"
          view    = "timeSeries"
          annotations = {
            horizontal = [{
              value = var.error_threshold
              label = "Threshold"
              color = "#ff0000"
            }]
          }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "Error Count - Auth Service"
          region  = var.aws_region
          metrics = [["CardioOne/LogMetrics", "ErrorCount-auth-service"]]
          period  = 300
          stat    = "Sum"
          view    = "timeSeries"
          annotations = {
            horizontal = [{
              value = var.error_threshold
              label = "Threshold"
              color = "#ff0000"
            }]
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "Error Count - API Service"
          region  = var.aws_region
          metrics = [["CardioOne/LogMetrics", "ErrorCount-api-service"]]
          period  = 300
          stat    = "Sum"
          view    = "timeSeries"
          annotations = {
            horizontal = [{
              value = var.error_threshold
              label = "Threshold"
              color = "#ff0000"
            }]
          }
        }
      }
    ]
  })
} 
data "aws_caller_identity" "current" {}