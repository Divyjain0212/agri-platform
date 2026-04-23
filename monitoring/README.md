# Monitoring with CloudWatch

This project uses **AWS CloudWatch** for all monitoring, logging, and alerting. 

## Note on Monitoring Setup

The files `prometheus.yml`, `docker-compose.yml`, and `cloudwatch-config.yml` in this directory were originally created as alternatives but are **not used** in the current deployment.

## CloudWatch Features Enabled

All monitoring is handled automatically by AWS CloudWatch:

- ✅ **ECS Container Insights** - Detailed container metrics
- ✅ **CloudWatch Logs** - Centralized log aggregation at `/ecs/agri-platform`
- ✅ **CloudWatch Metrics** - CPU, Memory, Network monitoring
- ✅ **CloudWatch Alarms** - Automated alerts for thresholds
- ✅ **CloudWatch Dashboards** - Custom metric visualizations

## Accessing CloudWatch

1. **AWS Console**: https://console.aws.amazon.com/cloudwatch
2. **View Logs**: `aws logs tail /ecs/agri-platform --follow`
3. **Create Dashboards**: In CloudWatch Console → Dashboards
4. **Set Alarms**: CloudWatch Console → Alarms

See [DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md#step-6-configure-cloudwatch-monitoring) for detailed instructions.
