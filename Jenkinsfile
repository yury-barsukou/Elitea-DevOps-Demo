pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'localhost:5000'
        DOCKER_IMAGE = 'myapp'
        DOCKER_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-pat-id', url: 'https://github.com/sathishravigithub/LLM.git'
            }
        }

        stage('Build Image') {
            steps {
                sh 'eval $(minikube docker-env)'
                sh 'docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG} .'
                sh 'docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}'
            }
        }

        stage('Scan Image') {
            steps {
                sh 'trivy image ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
                sh 'sleep 120'
                sh 'kubectl rollout status deployment myapp || kubectl rollout undo deployment myapp'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
