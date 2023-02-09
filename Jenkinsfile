pipeline {

    agent any

    stages {

        stage('Checkout Codebase'){
            steps{
                checkout scm: [$class: 'GitSCM', branches: [[name: '*/dev']], userRemoteConfigs: [[credentialsId: 'jenkins', url: 'git@github.com:qqwerty222/jenkins-project.git' ]]]
            }
        }
    }
}