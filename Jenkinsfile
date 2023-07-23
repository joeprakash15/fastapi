pipeline {
    agent any

    stages {
        stage('SCM checkout') {
            steps {
                git 'https://github.com/joeprakash15/fastapi.git'  #this is my github repository that having our python application codes.
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonarscanner4'   #in jenkins level we need to configure sonarqube details, to integrate sonar with jenkins.
                    withSonarQubeEnv('sonar-pro') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=python-test"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                sleep(time: 35, unit: 'SECONDS')
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar'
                }
            }
        }

        stage('Build Docker Image and push') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerPass', variable: 'dockerPassword')]) {
                        sh "docker login -u joeprakashsoosai -p ${dockerPassword}"
                        sh "docker build -t joeprakashsoosai/fastapi:latest ."
                        sh "docker push joeprakashsoosai/fastapi:latest"
                        sh "docker rmi joeprakashsoosai/fastapi:latest"
                    }
                }
            }
        }

        stage('Approval - Deploy on k8s') {
            steps {
                input 'Approve for KOPS Deploy'
            }
        }

        stage ('Deploy on k8s') {
            steps {
                script {
                    withKubeCredentials(kubectlCredentials: [[credentialsId: 'k8s', namespace: 'default']]) {
                        sh 'kubectl apply -f deployment-python-fastapi.yml'
			sh 'kubectl apply -f service-python-fastapi.yml'
                    }
                }
            }
        }
    }
}
