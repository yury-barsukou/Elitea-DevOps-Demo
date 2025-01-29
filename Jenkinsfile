pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'localhost:5000' // Minikube Docker Registry
        APP_NAME = 'myapp'
        IMAGE_TAG = 'latest'
        PATH = "/opt/homebrew/bin:$PATH"
        DOCKER_TLS_VERIFY = '1'
        DOCKER_HOST = 'tcp://127.0.0.1:54509'
        DOCKER_CERT_PATH = '/Users/sathish_ravi/.minikube/certs'
        MINIKUBE_EXISTING_DOCKER_HOST = 'unix:///var/run/docker.sock'
        MINIKUBE_ACTIVE_DOCKERD = 'minikube'
        
    }

    stages {
        stage('Checkout Source Code') {
            
                steps {
                git branch: 'main', 
                    credentialsId: 'github-pat-id', 
                    url: 'https://github.com/sathishravigithub/LLM.git'
            
            }
        }

        stage('Set Minikube Environment') {
            steps {
                script {
                    sh 'eval $(minikube docker-env)'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t localhost:5000/myapp:latest .'
                }
            }
        }

        stage('Run Kubernetes Deployment') {
            steps {
                script {
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }
    }
}
