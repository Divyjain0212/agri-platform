pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REGION = "ap-south-1"   
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
                echo "Building Docker image..."
                sh '''
                    docker build --progress=plain \
                    -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .
                    
                    docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
                    ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    withAWS(region: 'ap-south-1', credentials: 'aws-credentials') {
                        sh '''
                            aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                            docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                echo "Deploying to ECS..."
                sh '''
                    aws ecs update-service \
                        --cluster agri-platform-cluster \
                        --service agri-platform-service \
                        --force-new-deployment \
                        --region ${AWS_REGION}
                '''
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker images..."
            sh 'docker rmi ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} || true'
        }
    }
}