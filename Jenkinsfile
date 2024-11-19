pipeline {
    agent any
    
    tools{
        maven 'maven3'
        jdk 'jdk17'
    }
    
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git-Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/Ashish89Rangari/Production-Level-CICD-Project.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Blogging-app -Dsonar.projectKey=Blogging-app \
                          -Dsonar.java.binaries=target'''
    
                }
            }
        }
        
        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        
        stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
                }
            }
        }
        
        stage('Docker Build & Tag') {
            steps {
                script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh "docker build -t ashishr99/bloggingapp:latest ."
                }
                }
            }
        }
        
        stage('Trivy Docker Image Scan') {
            steps {
                sh "trivy image --format table -o image.html ashishr99/bloggingapp:latest "
            }
        }
        
        stage('Docker Push Image') {
            steps {
                script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh "docker push ashishr99/bloggingapp:latest "
                }
                }
            }
        }
        
        stage('K8-Deploy') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'devopsshack-cluster', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://08C4F0F1CED5BF10FB87BA63E2BF4159.gr7.ap-south-1.eks.amazonaws.com') {
                    sh "kubectl apply -f deployment-service.yml"
                    sleep 20
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'devopsshack-cluster', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://08C4F0F1CED5BF10FB87BA63E2BF4159.gr7.ap-south-1.eks.amazonaws.com') {
                    sh "kubectl get pods"
                    sh "kubectl get svc"
                    
                }
            }
        }
        
    }
    
    post{
        always{
            script{
                def jobName = env.JOB_NAME 
                def buildNumber = env.BUILD_NUMBER 
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN' 
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
                
                def body = """ 
                    <html> 
                    <body> 
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;"> 
                    <h2>${jobName} - Build ${buildNumber}</h2> 
                    <div style="background-color: ${bannerColor}; padding: 10px;"> 
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3> 
                    </div> 
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p> 
                    </div> 
                    </body> 
                    </html> 
                """ 
                emailext ( 
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}", 
                    body: body, 
                    to: 'jaiswaladi246@gmail.com', 
                    from: 'jenkins@example.com', 
                    replyTo: 'jenkins@example.com', 
                    mimeType: 'text/html', 
                    attachmentsPattern: 'trivy-image-report.html' 
                ) 

            }
             
        }
        
    }
    
    
}
