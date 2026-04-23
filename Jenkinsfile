pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com"
        ECR_REPOSITORY = "agri-platform"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DJANGO_SETTINGS_MODULE = "agri_platform.settings"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh '''
                        docker build -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .
                        docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    '''
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Running tests..."
                    sh '''
                        docker run --rm \
                            -e DJANGO_SETTINGS_MODULE=agri_platform.settings \
                            ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
                            python manage.py test
                    '''
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    echo "Pushing to ECR..."
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    '''
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    echo "Deploying to ECS..."
                    sh '''
                        # Update ECS service to force new deployment
                        aws ecs update-service \
                            --cluster agri-platform-cluster \
                            --service agri-platform-service \
                            --force-new-deployment \
                            --region ${AWS_REGION}
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up Docker images..."
                sh 'docker rmi ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} || true'
            }
        }
        success {
            echo "Pipeline succeeded!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
