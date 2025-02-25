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
        stage('Checkout Code') {
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
                script {
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status != 'OK' && qualityGate.status != 'NONE') {
                        error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"
                    }
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                sh """
                docker build -t ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA} .
                docker push ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA}
                """
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
                        sh "helm upgrade --install ${APP_NAME} ./helm --set image.tag=${GIT_SHA}"
                    } else {
                        sh "sed -i 's|image: .*|image: ${DOCKER_REGISTRY}/${APP_NAME}:${GIT_SHA}|' deployment.yaml"
                        sh "kubectl apply -f deployment.yaml"
                    }
                }
            }
        }
    }

    post {
        failure {
            script {
                if (fileExists('helm/values.yaml')) {
                    sh "helm rollback ${APP_NAME} 1"
                } else {
                    sh "kubectl rollout undo deployment/${APP_NAME}"
                }
            }
        }
    }
}
