pipeline {

	agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '3', artifactNumToKeepStr: '3'))
    }

    tools {
        maven 'maven_3.9.4'
    }

    stages {
        stage('Code Compilation') {
            steps {
                echo 'Code Compilation is In Progress!'
                sh 'mvn clean compile'
                echo 'Code Compilation is Completed Successfully!'
            }
        }
        stage('Code QA Execution') {
            steps {
                echo 'JUnit Test Case Check in Progress!'
                sh 'mvn clean test'
                echo 'JUnit Test Case Check Completed!'
            }
        }
        stage('Code Package') {
            steps {
                echo 'Creating WAR Artifact'
                sh 'mvn clean package'
                echo 'Artifact Creation Completed'
            }
        }
        stage('Building & Tag Docker Image') {
            steps {
                echo "Starting Building Docker Image"
                sh "docker build -t satyam88/fusion-ms ."
                sh "docker build -t fusion-ms ."
                echo 'Docker Image Build Completed'
            }
        }
        stage('Docker Image Scanning') {
            steps {
                echo 'Docker Image Scanning Started'
                sh 'docker --version'
                echo 'Docker Image Scanning Started'
            }
        }
        stage(' Docker push to Docker Hub') {
           steps {
              script {
                 withCredentials([string(credentialsId: 'dockerhubCred', variable: 'dockerhubCred')]){
                 sh 'docker login docker.io -u satyam88 -p ${dockerhubCred}'
                 echo "Push Docker Image to DockerHub : In Progress"
                 sh 'docker push satyam88/fusion-ms:latest'
                 echo "Push Docker Image to DockerHub : In Progress"
                 }
              }
            }
        }
        stage(' Docker Image Push to Amazon ECR') {
           steps {
              script {
                 withDockerRegistry([credentialsId:'ecr:ap-south-1:ecr-credentials', url:"https://533267238276.dkr.ecr.ap-south-1.amazonaws.com"]){
                 sh """
                 echo "List the docker images present in local"
                 docker images
                 echo "Tagging the Docker Image: In Progress"
                 docker tag fusion-ms:latest 533267238276.dkr.ecr.ap-south-1.amazonaws.com/fusion-ms:latest
                 echo "Tagging the Docker Image: Completed"
                 echo "Push Docker Image to ECR : In Progress"
                 docker push 533267238276.dkr.ecr.ap-south-1.amazonaws.com/fusion-ms:latest
                 echo "Push Docker Image to ECR : Completed"
                 """
                 }
              }
           }
        }
        stage('Upload Docker Image to Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'docker login http://13.201.118.129:8085/repository/fusion-ms/ -u admin -p ${PASSWORD}'
                        echo "Push Docker Image to Nexus : In Progress"
                        sh 'docker tag fusion-ms 13.201.118.129:8085/fusion-ms:latest'
                        sh 'docker push 13.201.118.129:8085/fusion-ms'
                        echo "Push Docker Image to Nexus : Completed"
                    }
                }
            }
        }
    }
}
