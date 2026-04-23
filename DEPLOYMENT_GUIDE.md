# Phase 2: High-Availability Agri-Tech Platform Deployment Guide

## Overview

This deployment automates the provisioning of a multi-tier, high-availability agricultural platform on AWS using Terraform, Docker, and Jenkins CI/CD.

## Architecture

```
┌─────────────────────────────────────────┐
│         Internet Users                   │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────▼──────────┐
        │   Application       │
        │  Load Balancer      │
        │  (ap-south-1a, 1b)   │
        └──────────┬──────────┘
                   │
      ┌────────────┴────────────┐
      │                         │
┌─────▼────┐           ┌────────▼────┐
│   ECS     │           │    ECS      │
│  Tasks    │           │   Tasks     │
│  (AZ-1a)  │           │  (AZ-1b)    │
└─────┬────┘           └────────┬────┘
      │                         │
      └────────────┬────────────┘
                   │
        ┌──────────▼──────────┐
        │   PostgreSQL RDS    │
        │   Multi-AZ Database │
        │  (Replication)      │
        └─────────────────────┘
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **Docker** installed locally
4. **Jenkins** server (can be deployed on EC2)
5. **AWS CLI** configured with credentials
6. GitHub repository with webhook access

## Step 1: Prepare Environment Variables

```bash
cd d:/Django-project

# Copy example configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit with your values
# - AWS Region
# - Database credentials (STRONG PASSWORD)
# - Container image URI
```

## Step 2: Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name agri-platform \
  --region ap-south-1

# Note the repository URI
aws ecr describe-repositories \
  --repository-names agri-platform \
  --region ap-south-1 \
  --query 'repositories[0].repositoryUri'
```

## Step 3: Build and Push Docker Image

```bash
# Build image
docker build -t agri-platform:latest .

# Tag for ECR
docker tag agri-platform:latest <ECR_URI>:latest

# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin <ECR_URI>

# Push to ECR
docker push <ECR_URI>:latest

# Update terraform.tfvars
# container_image = "<ECR_URI>:latest"
```

## Step 4: Deploy Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -out=tfplan

# Review and apply
terraform apply tfplan
```

## Step 5: Configure Jenkins CI/CD Pipeline

### Jenkins Setup

1. Install Jenkins plugins:
   - Docker Pipeline
   - GitHub Integration
   - AWS credentials

2. Add AWS credentials to Jenkins:
   - Go to Manage Jenkins → Manage Credentials
   - Add AWS Access Key ID and Secret Access Key

3. Create Pipeline Job:
   - Job name: `agri-platform-deploy`
   - Pipeline script from SCM
   - Repository: Your GitHub repo
   - Script path: `Jenkinsfile`

### GitHub Webhook Setup

1. Go to GitHub repository settings
2. Add webhook:
   - Payload URL: `http://<jenkins-server>/github-webhook/`
   - Content type: `application/json`
   - Trigger: Push events
   - Active: ✓

## Step 6: Configure CloudWatch Monitoring

CloudWatch is automatically enabled in your infrastructure through the Terraform configuration:

- **ECS Container Insights**: Enabled for detailed metrics
- **Log Groups**: All ECS logs sent to `/ecs/agri-platform`
- **Log Retention**: 30 days
- **Metrics**: CPU, Memory, Network, and custom application metrics

### View Logs

```bash
# View live logs
aws logs tail /ecs/agri-platform --follow

# View specific time range
aws logs filter-log-events \
  --log-group-name /ecs/agri-platform \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --end-time $(date +%s)000
```

### Create CloudWatch Dashboards

1. Go to AWS CloudWatch Console
2. Create Dashboard: `agri-platform-monitoring`
3. Add widgets for:
   - ECS Service CPU/Memory utilization
   - RDS CPU/Connections
   - ALB healthy/unhealthy host counts
   - Request count and latency

### Set Up Alarms

```bash
# High CPU alarm
aws cloudwatch put-metric-alarm \
  --alarm-name agri-platform-high-cpu \
  --alarm-description "Alert when ECS CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2

# Database connection alarm
aws cloudwatch put-metric-alarm \
  --alarm-name agri-platform-db-connections \
  --alarm-description "Alert when DB connections exceed 50" \
  --metric-name DatabaseConnections \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 50 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

## Step 7: Test Deployment

```bash
# Get ALB DNS from Terraform output
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test endpoint
curl http://$ALB_DNS/
curl http://$ALB_DNS/api/market_price/

# Monitor logs
aws logs tail /ecs/agri-platform --follow
```

## Auto-Scaling Configuration

The infrastructure automatically scales based on:

- **CPU Utilization**: Target 70%
- **Memory Utilization**: Target 80%
- **Min Capacity**: 2 tasks
- **Max Capacity**: 10 tasks

Scale-out happens when:
- CPU > 70% for 2 minutes
- Memory > 80% for 2 minutes

Scale-down happens when:
- Utilization drops below thresholds for 5 minutes

## Database Backup & Recovery

### Automated Backups

- **Retention**: 30 days
- **Backup Window**: 03:00-04:00 UTC
- **Maintenance Window**: Monday 04:00-05:00 UTC

### Manual Snapshot

```bash
aws rds create-db-snapshot \
  --db-instance-identifier agri-platform-db \
  --db-snapshot-identifier agri-platform-snapshot-$(date +%Y%m%d-%H%M%S) \
  --region ap-south-1
```

## Monitoring Metrics

Key metrics to monitor:

- **Application**: CPU, Memory, Request Count, Response Time
- **Database**: CPU, Connections, Free Memory, Storage
- **Load Balancer**: Healthy/Unhealthy Hosts, Response Time, Request Count

## Cost Optimization

1. **Use Spot Instances**: Replace FARGATE with FARGATE_SPOT for non-critical workloads
2. **RDS**: Consider `db.t3.micro` for development, `db.t4g.small` for production
3. **ALB**: Idle timeouts set to 60 seconds
4. **CloudWatch**: Logs retention set to 30 days

## Troubleshooting

### ECS Tasks not starting

```bash
# Check task logs
aws logs tail /ecs/agri-platform --follow

# Describe service
aws ecs describe-services \
  --cluster agri-platform-cluster \
  --services agri-platform-service
```

### Database connection issues

```bash
# Check security group
aws ec2 describe-security-groups \
  --filters Name=group-name,Values=agri-platform-rds-sg
```

### ALB health check failures

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

## Cleanup & Destruction

```bash
# Remove Terraform resources
cd terraform
terraform destroy

# Delete ECR repository
aws ecr delete-repository \
  --repository-name agri-platform \
  --force \
  --region ap-south-1
```

## Next Steps

1. Set up SSL/TLS with AWS Certificate Manager
2. Configure CloudFront CDN for static assets
3. Implement database read replicas
4. Add WAF (Web Application Firewall)
5. Setup comprehensive monitoring dashboards
6. Configure SNS alerts for critical metrics

## Support

For issues or questions, refer to:
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Docker Documentation](https://docs.docker.com/)
