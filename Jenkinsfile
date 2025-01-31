pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-docker-registry'
        IMAGE_NAME = 'your-image-name'
        IMAGE_TAG = 'latest'
        KUBERNETES_NAMESPACE = 'your-namespace'
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
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/your-repo/build-code.git']]])
            }
        }

        stage('Set up Minikube Docker Env') {
            steps {
                sh 'eval $(minikube docker-env)'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    def podsReady = sh(script: "kubectl rollout status deployment/${env.IMAGE_NAME} -n ${env.KUBERNETES_NAMESPACE} --timeout=120s", returnStatus: true)
                    if (podsReady != 0) {
                        error('Deployment failed, rolling back...')
                    }
                }
            }
        }
    }

    post {
        failure {
            script {
                sh "kubectl rollout undo deployment/${env.IMAGE_NAME} -n ${env.KUBERNETES_NAMESPACE}"
            }
        }
        always {
            cleanWs()
        }
    }
}