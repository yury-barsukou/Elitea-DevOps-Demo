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
                sh 'sonar-scanner'
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
                script {
                    sh """
                    docker build -t ${env.DOCKER_REGISTRY}/${env.APP_NAME}:${env.GIT_SHA} .
                    docker push ${env.DOCKER_REGISTRY}/${env.APP_NAME}:${env.GIT_SHA}
                    """
                }
            }
        }

        stage('Security Scan') {
            steps {
                sh "trivy image ${env.DOCKER_REGISTRY}/${env.APP_NAME}:${env.GIT_SHA}"
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (fileExists('helm/values.yaml')) {
                        sh """
                        helm upgrade --install ${env.APP_NAME} ./helm --set image.repository=${env.DOCKER_REGISTRY}/${env.APP_NAME} --set image.tag=${env.GIT_SHA}
                        """
                    } else if (fileExists('deployment.yaml')) {
                        sh """
                        case "\$(uname -s)" in
                            Darwin*) sed -i '' 's|image: .*|image: ${env.DOCKER_REGISTRY}/${env.APP_NAME}:${env.GIT_SHA}|' deployment.yaml ;;
                            *) sed -i 's|image: .*|image: ${env.DOCKER_REGISTRY}/${env.APP_NAME}:${env.GIT_SHA}|' deployment.yaml ;;
                        esac
                        kubectl apply -f deployment.yaml
                        """
                    } else {
                        error "No deployment configuration found (helm/values.yaml or deployment.yaml)"
                    }
                }
            }
        }

        stage('Rollback') {
            steps {
                script {
                    // Add rollback mechanism here
                }
            }
        }
    }
}
