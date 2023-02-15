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
                catchError {
                    sh "docker build -t website:v${env.BUILD_NUMBER} ."
                    sh "docker run -i -v ${WORKSPACE}/junit_results.xml:/junit_results.xml website:v${env.BUILD_NUMBER} python -m pytest --junit-xml=/junit_results.xml"
                } 
            }
        }
        
        stage('Get test result') {
            steps{
                catchError(buildResult: 'FAILURE'){
                    archiveArtifacts artifacts: 'junit_results.xml'
                    junit 'junit_results.xml'
                }
                
                script {
                    if (currentBuild.currentResult == "FAILURE")
                        error 'Pytest failed'
                }
            }
        }        
       
        stage('Push image'){
            steps{
                sh "docker image tag website:v${env.BUILD_NUMBER} localhost:5000/website"
                sh "docker push localhost:5000/website"
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
}