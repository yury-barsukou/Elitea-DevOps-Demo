pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "localhost:5000"
        APP_NAME = "myapp"
        Sonar_Url = "https://localhost"
        Sonar_Token = "sonarqube"
        security_scan_tool = "trivy"
        GIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Static Code Analysis') {
            steps {
                sh "sonar-scanner"
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK' && qg.status != 'NONE') {
                        error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                sh "docker build -t ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA} ."
                sh "docker push ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA}"
            }
        }

        stage('Security Scan') {
            steps {
                sh "${security_scan_tool} image ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA}"
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (fileExists('helm/values.yaml')) {
                        sh "sed -i 's/tag:.*/tag: ${GIT_SHA}/' helm/values.yaml"
                        sh "helm upgrade --install ${APP_NAME} helm/ -f helm/values.yaml"
                    } else if (fileExists('deployment.yaml')) {
                        sh "sed -i 's|image:.*|image: ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA}|' deployment.yaml"
                        sh "kubectl apply -f deployment.yaml"
                    } else {
                        error "No deployment configuration found!"
                    }
                }
            }
        }
    }

    post {
        failure {
            script {
                // Rollback mechanism
                sh "kubectl rollout undo deployment/${APP_NAME}"
            }
        }
    }
}
