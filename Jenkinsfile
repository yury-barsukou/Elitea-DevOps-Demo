pipeline {
    agent any
    environment {
        APP_NAME = 'myapp'
        TAG = 'latest'
        REGISTRY = 'localhost:5000'
        KUBE_NAMESPACE = 'default'
    }
    stages {
        stage('Setup Environment') {
            steps {
                script {
                    echo "Environment setup with APP_NAME=${env.APP_NAME}, TAG=${env.TAG}, REGISTRY=${env.REGISTRY}"
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh 'docker build -t $REGISTRY/$APP_NAME:$TAG .'
                    sh 'docker push $REGISTRY/$APP_NAME:$TAG'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl apply -f deployment.yaml --namespace=$KUBE_NAMESPACE'
                    sh 'sleep 120' // Wait for 2 minutes
                }
            }
        }
    }
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker rmi $REGISTRY/$APP_NAME:$TAG'
        }
    }
}
