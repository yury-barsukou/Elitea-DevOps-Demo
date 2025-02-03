pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-docker-registry'
        IMAGE_NAME = 'your-image-name'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_REGISTRY) {
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Scan Docker Image') {
            steps {
                script {
                    def scanResult = sh(script: "trivy image --severity CRITICAL ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}", returnStatus: true)
                    if (scanResult != 0) {
                        error("Image scan failed with critical vulnerabilities.")
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl apply -f deployment.yaml'
                    sleep 120
                    def rolloutStatus = sh(script: 'kubectl rollout status deployment/your-deployment-name', returnStatus: true)
                    if (rolloutStatus != 0) {
                        sh 'kubectl rollout undo deployment/your-deployment-name'
                        error("Deployment failed, rolled back to the previous version.")
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
