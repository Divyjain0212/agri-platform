#!/bin/bash

# Build Docker image and push to ECR
set -e

AWS_REGION=${AWS_REGION:-ap-south-1}
ECR_REGISTRY=${ECR_REGISTRY}
ECR_REPOSITORY=${ECR_REPOSITORY:-agri-platform}
IMAGE_TAG=${IMAGE_TAG:-latest}

if [ -z "$ECR_REGISTRY" ]; then
    echo "Error: ECR_REGISTRY environment variable not set"
    exit 1
fi

IMAGE_URI="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "Building Docker image: $IMAGE_URI"
docker build -t $IMAGE_URI .

echo "Pushing image to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

docker push $IMAGE_URI

echo "Successfully pushed $IMAGE_URI"
echo "Update terraform.tfvars with container_image = \"$IMAGE_URI\""
