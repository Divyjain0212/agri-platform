#!/bin/bash
set -e

echo "Running database migrations..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

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
