pipeline {
    agent any
    stages {
        stage('Set Environment Variables') {
            steps {
                script {
                    env.LOCALHOST = 'localhost:5000'
                    env.APP_NAME = 'myapp'
                    env.APP_TAG = 'latest'
                    env.MINIKUBE_EXISTING_DOCKER_HOST = 'unix:///var/run/docker.sock'
                    env.DOCKER_HOST = 'tcp://127.0.0.1:54509'
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
        stage('Set Minikube Docker Env') {
            steps {
                script {
                    sh 'eval \
                        $(minikube -p minikube docker-env)'
                    env.DOCKER_ENV = sh(script: 'minikube -p minikube docker-env', returnStdout: true)
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'eval $(minikube -p minikube docker-env)'

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
