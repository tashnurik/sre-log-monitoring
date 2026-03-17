# CardioOne Log Monitoring & Alerting System

## Overview
This is a log monitoring and alerting system for production environment. 
WHat it does:
- Continiously collects logs from multiple services
- Analyzes them in near realtime
- Alerts the operations team when critical issues are detected.

## Problem Statement
Production services generate logs locally on each server and are reviewed only after incidents occur. 
I am going to centralize logs, it detects errors automatically, and alerting the team before issues escalate.

## Architecture
```
Multiple Services → CloudWatch Log Groups → Metric Filters → CloudWatch Alarms → SNS → Email Alert
```

## Tech Stack
- **Terraform** — for provisioning all AWS resources
- **AWS CloudWatch** — centralized log collection and monitoring
- **AWS CloudWatch Alarms** — threshold-based alerting
- **AWS SNS** — notification delivery via email
- **Bash** — log simulator script to test the system

## Repository Structure
```
cardioone-log-monitoring/
├── terraform/          # All infrastructure code
├── scripts/            # Log simulator script
├── screenshots/        # Project screenshots
└── README.md           # Project documentation
```

## Author
Nurtilek — Site Reliability Engineer