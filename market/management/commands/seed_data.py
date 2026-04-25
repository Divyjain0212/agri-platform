from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from market.models import Crop, MarketPrice
import os
import logging

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Seed database with initial market data and create admin user'

    def handle(self, *args, **options):
        # Create superuser if it doesn't exist
        username = os.getenv('DJANGO_SUPERUSER_USERNAME')
        email = os.getenv('DJANGO_SUPERUSER_EMAIL')
        password = os.getenv('DJANGO_SUPERUSER_PASSWORD')

        # Validate required environment variables
        if not username:
            raise ValueError(
                "DJANGO_SUPERUSER_USERNAME environment variable is not set")
        if not email:
            raise ValueError(
                "DJANGO_SUPERUSER_EMAIL environment variable is not set")
        if not password:
            raise ValueError(
                "DJANGO_SUPERUSER_PASSWORD environment variable is not set (must be fetched from AWS Secrets Manager)")

        try:
            if not User.objects.filter(username=username).exists():
                User.objects.create_superuser(
                    username=username,
                    email=email,
                    password=password
                )
                self.stdout.write(self.style.SUCCESS(
                    f'Created superuser: {username}'))
                logger.info(f'Superuser created: {username}')
            else:
                self.stdout.write(self.style.WARNING(
                    f'Superuser already exists: {username}'))
                logger.info(f'Superuser already exists: {username}')
        except Exception as e:
            self.stdout.write(self.style.ERROR(
                f'Error creating superuser: {str(e)}'))
            logger.error(f'Error creating superuser: {str(e)}')
            raise

        # Create crops if they don't exist
        try:
            crops = ['Rice', 'Wheat', 'Corn', 'Cotton', 'Sugarcane']
            for crop_name in crops:
                Crop.objects.get_or_create(name=crop_name)
            self.stdout.write(self.style.SUCCESS('Created crops'))
            logger.info('Crops created successfully')
        except Exception as e:
            self.stdout.write(self.style.ERROR(
                f'Error creating crops: {str(e)}'))
            logger.error(f'Error creating crops: {str(e)}')
            raise

        # Create sample market prices
        try:
            sample_data = [
                {'crop': 'Rice', 'price': 45.50, 'location': 'Delhi'},
                {'crop': 'Wheat', 'price': 35.00, 'location': 'Punjab'},
                {'crop': 'Corn', 'price': 28.75, 'location': 'Maharashtra'},
                {'crop': 'Cotton', 'price': 52.25, 'location': 'Gujarat'},
                {'crop': 'Sugarcane', 'price': 38.00, 'location': 'Tamil Nadu'},
            ]

            for data in sample_data:
                crop = Crop.objects.get(name=data['crop'])
                MarketPrice.objects.get_or_create(
                    crop=crop,
                    location=data['location'],
                    defaults={'price': data['price']}
                )
            self.stdout.write(self.style.SUCCESS('Created market prices'))
            logger.info('Market prices created successfully')
        except Exception as e:
            self.stdout.write(self.style.ERROR(
                f'Error creating market prices: {str(e)}'))
            logger.error(f'Error creating market prices: {str(e)}')
            raise

        self.stdout.write(self.style.SUCCESS('Successfully seeded database'))
