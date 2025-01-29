pipeline {
    agent any
    stages {
        stage('Set Environment Variables') {
            steps {
                script {
                    env.LOCAL_HOST = 'localhost:5000'
                    env.APP_NAME = 'myapp'
                    env.IMAGE_TAG = 'latest'
                }
            }
        }
        stage('Checkout Source Code') {
            steps {
                script {
                    git branch: 'main', credentialsId: 'github-pat-id', url: 'https://github.com/sathishravigithub/LLM.git'
                }
            }
        }
        stage('Set Minikube Docker Environment') {
            steps {
                sh 'eval $(minikube docker-env)'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t localhost:5000/myapp:latest .'
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'docker push localhost:5000/myapp:latest'
            }
        }
        stage('Run Kubernetes Deployment') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
}