pipeline {

    agent {label 'terraform_docker'}
    triggers { pollSCM('* * * * *') }
    stages { 
        stage('Prepare Codebase'){
            steps{
                cleanWs()
                checkout scm: [$class: 'GitSCM', branches: [[name: '*/dev']], userRemoteConfigs: 
                [[credentialsId: 'ssh-github', url: 'git@github.com:qqwerty222/jenkins-project.git' ]]]
            }
        }
        stage('Run tests'){
            steps{
                dir('terraform/live') {
                    sh 'terraform init'
                    sh 'terraform destroy -target=module.test_node -target=module.python_website -auto-approve'
                    sh 'terraform apply -target=module.python_website -target=module.test_node -auto-approve'
                }
                sleep 10  // container need time to rewrite mounted result.xml
            }
        }
        
        stage('Get test result') {
            steps{
                archiveArtifacts artifacts: 'website/tests/*.xml'
                junit 'website/tests/*.xml'
            }
        }
            
        stage('Update website'){
            steps {
                dir('terraform/live') {
                    script {
                        if (currentBuild.currentResult == "SUCCESS") {
                            sh 'terraform destroy -target=module.prod_node -auto-approve'
                            sh 'terraform apply -target=module.prod_node -auto-approve'
                        }
                    }
                }   
            }
        }
    }
}