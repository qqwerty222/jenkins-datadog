pipeline {

    agent {label 'terraform_docker'}
    triggers { pollSCM('* * * * *') }
    environment {
        DATADOG_API_KEY = credentials('datadog_api_key')
        DATADOG_APP_KEY = credentials('datadog_app_key')
        TF_VAR_DATADOG_API_KEY = credentials('datadog_api_key')
        TF_VAR_WEBSITE_NODE_COUNT = 4
    }
    
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
                catchError {
                    sh "docker build -t website:v${env.BUILD_NUMBER} test_website/."
                    sh "docker run --name website_v${env.BUILD_NUMBER} -i -v ${WORKSPACE}/test_website/junit_results.xml:/junit_results.xml website:v${env.BUILD_NUMBER} python -m pytest --junit-xml=/junit_results.xml"
                } 
            }
        }
        
        stage('Get test result') {
            steps{
                catchError(buildResult: 'FAILURE'){
                    archiveArtifacts artifacts: 'test_website/junit_results.xml'
                    junit 'test_website/junit_results.xml'
                }
                
                script {
                    if (currentBuild.currentResult == "FAILURE")
                        error 'Pytest failed'
                }
            }
        }        
       
        stage('Push image'){
            steps{
                sh "docker image tag website:v${env.BUILD_NUMBER} localhost:5005/website"
                sh "docker push localhost:5005/website"
            }
        }
        
        stage('Update website'){
            steps {
                // left label in logs, to understand by what build they were created
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/gunicorn/access.log"
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/gunicorn/error.log"
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/nginx/access.log"
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/nginx/error.log"

                dir('terraform/live') {
                    sh 'terraform init'
                    sh 'terraform destroy -auto-approve'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rm  website_v${env.BUILD_NUMBER}"
            sh "docker rmi website:v${env.BUILD_NUMBER}"
        }
    }
}

