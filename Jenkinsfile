pipeline {
    agent any

     environment {
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = 'latest'
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
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh 'eval $(minikube docker-env)'
                    sh "docker build -t ${imageTag} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker push ${imageTag}"
                }
            }
        }


        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def imageTag = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "kubectl set image -n ${env.KUBERNETES_NAMESPACE} deployment/${env.IMAGE_NAME} ${env.IMAGE_NAME}=${imageTag}"
                    sh "kubectl rollout status -n ${env.KUBERNETES_NAMESPACE} deployment/${env.IMAGE_NAME} --timeout=120s"
                }
            }
            post {
                failure {
                    sh "kubectl rollout undo -n ${env.KUBERNETES_NAMESPACE} deployment/${env.IMAGE_NAME}"
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
