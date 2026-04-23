output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the load balancer"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN of the load balancer"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "Name of the ECS cluster"
}

output "ecs_service_name" {
  value       = aws_ecs_service.app.name
  description = "Name of the ECS service"
}

output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "RDS database endpoint"
}

output "rds_database_name" {
  value       = aws_db_instance.main.db_name
  description = "RDS database name"
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.ecs.name
  description = "CloudWatch log group for ECS"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}
