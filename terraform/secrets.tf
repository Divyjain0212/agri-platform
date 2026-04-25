# Secrets Manager - Database Password
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}-db-password"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# Secrets Manager - Django Superuser Password
resource "aws_secretsmanager_secret" "django_superuser_password" {
  name                    = "${var.project_name}-django-superuser-password"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-django-superuser-password"
  }
}

resource "aws_secretsmanager_secret_version" "django_superuser_password" {
  secret_id     = aws_secretsmanager_secret.django_superuser_password.id
  secret_string = var.django_superuser_password
}
