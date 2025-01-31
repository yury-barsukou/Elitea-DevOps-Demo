pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-docker-registry'
        IMAGE_NAME = 'your-image-name'
        KUBECONFIG_CREDENTIALS = credentials('kubeconfig')
    }

    stages {
        stage('Build') {
            when {
                branch 'main'
            }
            steps {
                echo 'Running pipeline for the main branch'
            }
        }
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-pat-id', url: 'https://github.com/sathishravigithub/LLM.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    docker.build("${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}").push()
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def trivyScan = sh(script: "trivy image --exit-code 1 ${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}", returnStatus: true)
                    if (trivyScan != 0) {
                        error("Trivy scan failed")
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        sh 'kubectl apply -f deployment.yaml'
                    } catch (Exception e) {
                        sh 'kubectl rollout undo deployment/your-deployment-name'
                        error("Deployment failed and rolled back")
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
