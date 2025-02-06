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
                     def applyStatus = sh(script: "kubectl apply -f deployment.yaml --namespace=$KUBE_NAMESPACE", returnStatus: true)

    if (applyStatus != 0) {
        echo "⚠️ Warning: kubectl apply failed, but continuing..."
    }
                    // Check rollout status
    
                    def rolloutStatus = sh(script: "kubectl rollout status deployment/$APP_NAME --namespace=$KUBE_NAMESPACE", returnStatus: true)
                    if (rolloutStatus != 0) {
                        echo "Deployment failed, rolling back..."
                        sh "kubectl rollout undo deployment/$APP_NAME --namespace=$KUBE_NAMESPACE"
                    }
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
