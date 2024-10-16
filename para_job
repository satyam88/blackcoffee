pipeline {
    agent any
    parameters {
        string(name: 'maven_version', defaultValue: '3.9.3', description: 'Pass the version of Maven')
        string(name: 'terraform_version', defaultValue: '1.8.5', description: 'Pass the version of Terraform')		
    }
    stages {
        stage('Download Maven') {
            steps {
                sh '''
                cd /var/lib/jenkins/
                sudo wget https://dlcdn.apache.org/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz
                '''
            }
        }
        stage('Download Terraform') {
            steps {
                sh '''
                cd /opt
                sudo wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
                '''
            }
        }		
    }
