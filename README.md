# Agri-Tech Platform 🌾

A **high-availability agricultural market platform** providing real-time market prices to farmers with a modern, scalable cloud-native architecture.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [Production Deployment](#production-deployment)
- [API Documentation](#api-documentation)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## 🎯 Overview

This platform addresses the challenge of market price accessibility for farmers by providing:
- **Real-time market prices** across multiple locations
- **High availability** with multi-AZ deployment
- **Auto-scaling** to handle traffic spikes (especially at sunrise)
- **REST API** for easy integration
- **CloudWatch monitoring** for operational insights

### Key Stats
- **Language**: Python 3.13
- **Framework**: Django 6.0.4
- **Database**: PostgreSQL 15.4
- **Deployment**: AWS (ECS Fargate, RDS, ALB)
- **Infrastructure**: Terraform (IaC)
- **CI/CD**: Jenkins

---

## 🏗️ Architecture

### Multi-Tier High-Availability Setup

```
┌─────────────────────────────────────────┐
│         Internet Users                  │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────▼──────────────┐
        │  Application Load       │
        │  Balancer (ALB)         │
        │  (ap-south-1a, 1b)      │
        └──────────┬──────────────┘
                   │
      ┌────────────┴────────────┐
      │                         │
┌─────▼────┐           ┌────────▼────┐
│   ECS    │           │    ECS      │
│  Fargate │           │  Fargate    │
│  Tasks   │           │  Tasks      │
│  (AZ-1a) │           │  (AZ-1b)    │
└─────┬────┘           └────────┬────┘
      │                         │
      └────────────┬────────────┘
                   │
        ┌──────────▼──────────┐
        │   PostgreSQL RDS    │
        │   Multi-AZ          │
        └─────────────────────┘
```

### Key Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Load Balancer** | AWS ALB | Distribute traffic across AZs |
| **Container Orchestration** | AWS ECS (Fargate) | Run containerized Django app |
| **Database** | PostgreSQL RDS | Store market prices & farmer data |
| **Caching** | (Optional) ElastiCache | Improve response times |
| **Monitoring** | CloudWatch | Logs, metrics, alarms |
| **Infrastructure** | Terraform | IaC for reproducible deployments |
| **CI/CD** | Jenkins | Automated build & deployment |

---

## ✨ Features

### Application Features
- ✅ **Market Price Management** - Track prices across locations
- ✅ **Farmer Profiles** - Manage farmer information
- ✅ **RESTful API** - Easy integration with Tastypie
- ✅ **Multi-location Support** - Different prices per location
- ✅ **Automated Backups** - 30-day RDS backup retention

### Infrastructure Features
- ✅ **High Availability** - Multi-AZ deployment
- ✅ **Auto-Scaling** - Scale based on CPU (70%) & Memory (80%)
- ✅ **CloudWatch Integration** - Complete observability
- ✅ **Infrastructure as Code** - Terraform for reproducibility
- ✅ **Automated CI/CD** - Jenkins pipeline

---

## 🚀 Quick Start

### Prerequisites

- Python 3.13+
- Docker (for containerization)
- AWS Account (for deployment)
- Git

### Local Development Setup

#### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/agri-platform.git
cd agri-platform
```

#### 2. Create Virtual Environment
```bash
python -m venv env

# Windows
env\Scripts\activate

# macOS/Linux
source env/bin/activate
```

#### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

#### 4. Run Migrations
```bash
python manage.py migrate
```

#### 5. Create Superuser (Optional)
```bash
python manage.py createsuperuser
```

#### 6. Start Development Server
```bash
python manage.py runserver 8080
```

✅ Open http://localhost:8080/

---

## 💻 Local Development

### Project Structure
```
agri_platform/
├── agri_platform/           # Project settings
│   ├── settings.py          # Django configuration
│   ├── urls.py              # URL routing
│   └── wsgi.py              # WSGI application
├── market/                  # Market app
│   ├── models.py            # Crop, Farmer, MarketPrice models
│   ├── views.py             # Market views
│   ├── urls.py              # Market URLs
│   └── migrations/          # Database migrations
├── api/                     # API app
│   ├── models.py            # Tastypie resources
│   └── views.py             # API views
├── templates/               # HTML templates
├── manage.py                # Django CLI
├── requirements.txt         # Python dependencies
└── Dockerfile               # Container definition
```

### Database

**Local**: SQLite (`db.sqlite3`)
```bash
python manage.py migrate
python manage.py dbshell
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/market_price/` | GET | List all market prices |
| `/api/market_price/{id}/` | GET | Get specific price |
| `/market/` | GET | Market index page |
| `/market/{id}/` | GET | Market detail page |
| `/admin/` | GET | Django admin panel |

### Example API Calls

```bash
# Get all market prices
curl http://localhost:8080/api/market_price/

# Sample response
{
  "meta": {
    "limit": 20,
    "next": null,
    "offset": 0,
    "previous": null,
    "total_count": 2
  },
  "objects": [
    {
      "id": 1,
      "crop": "Rice",
      "location": "MP",
      "price": 2200,
      "resource_uri": "/api/market_price/1/"
    }
  ]
}
```

---

## ☁️ Production Deployment

### Step 1: Create AWS Resources

```bash
# Create ECR repository
aws ecr create-repository \
  --repository-name agri-platform \
  --region ap-south-1

# Note the URI
```

### Step 2: Build & Push Docker Image

```bash
# Build image
docker build -t agri-platform:latest .

# Tag for ECR
docker tag agri-platform:latest <ECR_URI>:latest

# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin <ECR_URI>

# Push
docker push <ECR_URI>:latest
```

### Step 3: Configure Terraform

```bash
# Copy template
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit configuration
nano terraform/terraform.tfvars
# Update: container_image, db_password, aws_region
```

### Step 4: Deploy Infrastructure

```bash
cd terraform

# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Get outputs
terraform output
```

### Step 5: Verify Deployment

```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test endpoints
curl http://$ALB_DNS/
curl http://$ALB_DNS/api/market_price/

# View logs
aws logs tail /ecs/agri-platform --follow
```

### Environment Variables

Set in ECS task definition via Terraform:

| Variable | Value | Example |
|----------|-------|---------|
| `DB_ENGINE` | postgresql | postgresql |
| `DB_NAME` | agridb | agridb |
| `DB_USER` | agriuser | agriuser |
| `DB_HOST` | RDS endpoint | agri-platform-db.abc123.ap-south-1.rds.amazonaws.com |
| `DB_PORT` | 5432 | 5432 |
| `DB_PASSWORD` | (from Secrets Manager) | - |
| `DEBUG` | False | False |
| `ALLOWED_HOSTS` | ALB DNS | agri-platform-alb-123.ap-south-1.elb.amazonaws.com |

---

## 📊 Monitoring

### CloudWatch

All logs and metrics are automatically sent to CloudWatch:

- **Log Group**: `/ecs/agri-platform`
- **Log Retention**: 30 days
- **Container Insights**: Enabled

### View Logs

```bash
# Real-time tail
aws logs tail /ecs/agri-platform --follow

# Search for errors
aws logs filter-log-events \
  --log-group-name /ecs/agri-platform \
  --filter-pattern "ERROR"
```

### Create Alarms

```bash
# High CPU alarm
aws cloudwatch put-metric-alarm \
  --alarm-name agri-platform-high-cpu \
  --alarm-description "Alert when CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

### Dashboard

Access CloudWatch dashboard in AWS Console:
1. CloudWatch → Dashboards
2. Create dashboard `agri-platform-monitoring`
3. Add widgets for key metrics

---

## 🔄 CI/CD Pipeline

### Jenkins Setup

1. **Create EC2 Instance** with Jenkins
2. **Install Plugins**:
   - Docker Pipeline
   - GitHub Integration
   - AWS credentials

3. **Add Credentials**:
   - AWS Access Key ID
   - AWS Secret Access Key
   - GitHub personal access token

4. **Create Pipeline Job**:
   - Job name: `agri-platform-deploy`
   - Pipeline script from SCM
   - Repository: `https://github.com/YOUR_USERNAME/agri-platform`
   - Script path: `Jenkinsfile`

### GitHub Webhook

1. Go to GitHub repo → Settings → Webhooks
2. Add webhook:
   - Payload URL: `http://<jenkins-server>:8080/github-webhook/`
   - Content type: `application/json`
   - Events: Push events
   - Active: ✓

### Pipeline Stages

```
Checkout → Build → Test → Push to ECR → Deploy to ECS
```

---

## 🆘 Troubleshooting

### Local Issues

#### Port Already in Use
```bash
# Kill process on port 8080
lsof -ti:8080 | xargs kill -9
```

#### Database Migration Errors
```bash
# Fresh start
rm db.sqlite3
python manage.py migrate
```

#### Module Not Found
```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### AWS Deployment Issues

#### ECS Task Not Starting
```bash
# Check task logs
aws logs tail /ecs/agri-platform --follow

# Describe service
aws ecs describe-services \
  --cluster agri-platform-cluster \
  --services agri-platform-service
```

#### Database Connection Failed
```bash
# Check security group
aws ec2 describe-security-groups \
  --filters Name=group-name,Values=agri-platform-rds-sg

# Test connection
psql -h <RDS_ENDPOINT> -U agriuser -d agridb
```

#### ALB Health Check Failing
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <TG_ARN>
```

---

## 📈 Performance Tips

1. **Database**: Enable RDS performance insights
2. **Caching**: Add Redis (ElastiCache) for API responses
3. **Static Files**: Use CloudFront CDN
4. **Monitoring**: Set up SNS alerts for critical metrics
5. **Auto-Scaling**: Adjust CPU/Memory thresholds based on actual load

---

## 🔐 Security Best Practices

✅ **Implemented**:
- Non-root container user
- Encrypted RDS storage
- Security groups for traffic control
- Secrets Manager for sensitive data
- HTTPS ready (ALB supports SSL/TLS)

**TODO**:
- [ ] Add AWS WAF (Web Application Firewall)
- [ ] Enable VPC Flow Logs
- [ ] Setup CloudTrail for audit logs
- [ ] Implement rate limiting on API
- [ ] Add authentication to API endpoints

---

## 💡 Scaling Strategy

### Vertical Scaling (RDS)
```bash
# Upgrade database instance
aws rds modify-db-instance \
  --db-instance-identifier agri-platform-db \
  --db-instance-class db.t4g.small \
  --apply-immediately
```

### Horizontal Scaling (ECS)
- **Auto-scaling enabled**: 2-10 tasks
- **CPU Target**: 70%
- **Memory Target**: 80%

---

## 📝 Contributing

1. Fork repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

---

## 📚 Documentation

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Detailed deployment instructions
- [Terraform Documentation](terraform/README.md) - Infrastructure details
- [Django Documentation](https://docs.djangoproject.com/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 📞 Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review AWS CloudWatch logs
3. Check Terraform state: `terraform show`
4. Create GitHub issue with error details

---

## 🎉 Quick Reference

### Common Commands

```bash
# Local Development
python manage.py runserver 8080
python manage.py migrate
python manage.py createsuperuser

# Docker
docker build -t agri-platform:latest .
docker run -p 8000:8000 agri-platform:latest

# Terraform
terraform init
terraform plan
terraform apply
terraform destroy

# AWS CLI
aws logs tail /ecs/agri-platform --follow
aws ecs describe-services --cluster agri-platform-cluster --services agri-platform-service
aws rds describe-db-instances --db-instance-identifier agri-platform-db
```

---

**Made with ❤️ for Indian Farmers** 🌾
