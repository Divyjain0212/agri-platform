# Main Terraform configuration file
# This file serves as the entry point for the Terraform configuration

# All resources are defined in separate files:
# - provider.tf: AWS provider configuration
# - variables.tf: Input variables
# - vpc.tf: VPC, subnets, and networking
# - security_groups.tf: Security groups for ALB, ECS, and RDS
# - rds.tf: PostgreSQL RDS database
# - ecs.tf: ECS cluster, service, task definitions, ALB, and auto-scaling
# - secrets.tf: AWS Secrets Manager for sensitive data
# - outputs.tf: Output values
