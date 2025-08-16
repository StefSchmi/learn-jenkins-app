pipeline {
    agent any

    environment {
        INDEX_FILE_NAME = 'index.html'
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
        
    }
    stages {
        // THis is build step
        /*
            Everything will explained.
         */

        //  stage('Docker') {
        //     steps {
        //         sh 'docker build -t my-playwright .'
        //     }
        //  }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "--entrypoint=''"
                }
            }
            //environment {
                //AWS_S3_BUCKET ='learn-jenkins-202508021327'
            //}
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        # aws s3 ls
                        # echo "Hello S3!" > index.html
                        # aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
                        # aws s3 sync build s3://$AWS_S3_BUCKET
                        aws ecs register-task-definition --cli-input-json file://aws/task-defintion-prod.json
                        aws ecs update-service --cluster LeanrJenkinsApp-Cluster-Prod-20250815 --service LearnJenkinsApp-TaskDefintion-Prod-service-xzgdoz42 --task-defintion LearnJenkinsApp-TaskDefintion-Prod:2
                    '''
                }
                
            }
        }

        
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }


    }
    
}