pipeline {
    agent any

    environment {
        INDEX_FILE_NAME = 'index.html'
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'LeanrJenkinsApp-Cluster-Prod-20250815'
        AWS_ECS_SERVICE_PROD = 'LearnJenkinsApp-TaskDefintion-Prod-service-xzgdoz42'
        AWS_ECS_TD_PROD = 'LearnJenkinsApp-TaskDefintion-Prod'

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

        stage('Build Docker image') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }

            steps {
                sh '''
                    amazon-linux-extras install docker
                    docker build -t myjenkinsapp .
                '''
            }
         }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "-u root --entrypoint=''"
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
                        yum install jq -y
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-defintion-prod.json | jq '.taskDefinition.revision')
                        echo $LATEST_TD_REVISION
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
                    '''
                }
                
            }
        }


    }
    
}