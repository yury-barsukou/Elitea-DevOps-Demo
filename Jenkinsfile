pipeline {
   environment {
     DOCKER_REGISTRY = 'localhost:5000'
     APP_NAME='myapp'
     GIT_SHA = '${GIT_COMMIT.substring(0,7)}'
     security_scan_tool = 'trivy'
   }
   agent any
   stages {
     stage('Checkout') {
       steps {
         git branch: 'main', url: 'https://github.com/sathishravigithub/LLM.git'
       }
     }
     
     stage('Sonar Analysis') {
       steps {
         script {
           if(fileExists('sonar-project.properties')) {
             sh 'sonar-scanner'
           } else {
             //sh 'sonar-scanner -Dsonar.projectKey=myapp -Dsonar.sources=. -Dsonar.host.url=http://localhost:9000 -Dsonar.login=admin -Dsonar.password=admin'
                withSonarQubeEnv('SonarQube') {  // Ensure 'SonarQube' matches your Jenkins global tool name
                        sh '''
                            sonar-scanner \
                            -Dsonar.projectKey=mymlpocs \
                            -Dsonar.organization=mymlpocs \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=https://sonarcloud.io \
                            -Dsonar.login=${SONAR_TOKEN}
                        '''
                    }
           }
         }
       }
     }
     stage('Quality Gate') {
       steps {
         waitForQualityGate abortPipeline: true
       }
     }
     stage('Build Docker Image') {
       steps {
         script {
           sh 'docker build -t $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA .'
           sh 'docker push $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA'
         }
       }
     }
     stage('Trivy Scan') {
       steps {
         sh 'trivy image --severity=HIGH,CRITICAL $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA'
       }
     }
     stage('Deploy') {
       steps {
         script {
           if(fileExists('helm')) {
             sh 'helm upgrade --install myapp helm --set image.repository=$DOCKER_REGISTRY/$APP_NAME,image.tag=$GIT_SHA'
           } else {
             sh 'sed -i "s|image: .*|image: $DOCKER_REGISTRY/$APP_NAME:$GIT_SHA|" deployment.yaml'
             sh 'kubectl apply -f deployment.yaml'
           }
         }
       }
     }
   }
   post {
     failure {
       script {
         if(fileExists('helm')) {
           sh 'helm rollback myapp'
         } else {
           sh 'kubectl rollout undo deployment/myapp'
         }
       }
     }
   }
 } 
