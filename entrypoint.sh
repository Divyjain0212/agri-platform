#!/bin/bash
set -e

# Fetch credentials from AWS Secrets Manager
echo "Fetching credentials from AWS Secrets Manager..."

python << 'EOF'
import json
import os
import boto3
from botocore.exceptions import ClientError

def get_secret(secret_name, region_name):
    """Fetch secret from AWS Secrets Manager"""
    try:
        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name
        )
        response = client.get_secret_value(SecretId=secret_name)
        return response['SecretString']
    except ClientError as e:
        print(f"Error fetching secret {secret_name}: {e}")
        raise

try:
    region = os.getenv('AWS_REGION', 'ap-south-1')
    project_name = os.getenv('PROJECT_NAME', 'agri-platform')
    
    # Fetch Django superuser password
    django_password_secret_name = f"{project_name}-django-superuser-password"
    django_password = get_secret(django_password_secret_name, region)
    os.environ['DJANGO_SUPERUSER_PASSWORD'] = django_password
    
    # Fetch DB password (optional, if needed)
    db_password_secret_name = f"{project_name}-db-password"
    try:
        db_password = get_secret(db_password_secret_name, region)
        os.environ['DB_PASSWORD'] = db_password
    except:
        print("Warning: Could not fetch DB password from Secrets Manager")
    
    print("Credentials fetched successfully")
except Exception as e:
    print(f"Failed to fetch credentials: {e}")
    raise
EOF

echo "Running database migrations..."
python manage.py migrate

echo "Seeding database with initial data and creating superuser..."
python manage.py seed_data

echo "Collecting static files (including admin)..."
python manage.py collectstatic --noinput --clear

echo "Starting application..."
exec gunicorn \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --worker-class sync \
    --worker-tmp-dir /dev/shm \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    agri_platform.wsgi:application
