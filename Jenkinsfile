pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = 'localhost:5000'
        APP_NAME = 'myapp'
        GIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                sh '''
                    docker build -t $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA .
                    docker push $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA
                '''
            }
        }
        stage('Security Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    sed -i 's|image: .*|image: $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA|' deployment.yaml
                    kubectl apply -f deployment.yaml
                '''
            }
        }
    }
    post {
        failure {
            echo 'Rolling back to previous stable build...'
            sh 'kubectl rollout undo deployment/$APP_NAME'
        }
    }
}
