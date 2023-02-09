pipeline {

    agent any

    stages {

        stage('Checkout Codebase'){
            steps{
                checkout scm: [$class: 'GitSCM', branches: [[name: '*/dev']], userRemoteConfigs: 
                [[credentialsId: 'ssh-github', url: 'git@github.com:qqwerty222/jenkins-project.git' ]]]
            }
        }
        stage('Build stage'){
            steps{
                sh 'echo $PWD'
            }
        }
    }
}