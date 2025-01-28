pipeline {
    agent any
    triggers {
        githubPush() // This listens for webhook triggers
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

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
        stage('Checkout Code') {
            steps {
                script {
                    // Use credentials for GitHub
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/sathishravigithub/LLM.git',
                            credentialsId: 'github-pat-id' // Replace with your credentials ID
                        ]]
                    ])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Use Minikube's Docker daemon
                   // sh 'export PATH=$PATH:/opt/homebrew/bin'
                    sh 'echo $PATH'
                    
                    sh 'eval $(minikube docker-env)'
                    sh 'docker info'
                    //sh 'eval $(minikube' -p minikube 'docker-env)'
                    sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${APP_NAME}:${IMAGE_TAG} localhost:5000/${APP_NAME}:${IMAGE_TAG}"
                    sh "docker push localhost:5000/${APP_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Apply Kubernetes manifests
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }
    }

    post {
        always {
            script {
                // Verify deployment
                sh 'kubectl get pods'
                sh 'kubectl get svc'
            }
        }
    }
}
