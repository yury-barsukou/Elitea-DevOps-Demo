pipeline {
    agent any
    stages {
        stage('Set Environment Variables') {
            steps {
                script {
                     withEnv([
                         'MYAPP_URL=localhost:5000',
                         'MYAPP_TAG=latest',
                         'PATH=/opt/homebrew/bin:$PATH'
    ]) {
                        //sh 'minikube start'
                    }
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
        stage('Set Minikube Environment') {
            steps {
                sh 'eval $(minikube docker-env)'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t localhost:5000/myapp:latest .'
            }
        }
        stage('Run Kubernetes Deployment') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
}
