pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-docker-registry'
        IMAGE_NAME = 'your-image-name'
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
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("https://${env.DOCKER_REGISTRY}") {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    kubernetesDeploy(configs: 'deployment.yaml', kubeconfigId: 'kubeconfig')
                }
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