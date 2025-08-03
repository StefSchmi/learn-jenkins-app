pipeline {
    agent any

    environment {
        INDEX_FILE_NAME = 'index.html'
        NETLIFY_SITE_ID = 'a09236b1-d9df-4f0e-a43e-7fe52ebaafc9'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        
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

        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                }
            }
            environment {
                AWS_S3_BUCKET ='learn-jenkins-202508021327'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        # aws s3 ls
                        echo "Hello S3!" > index.html
                        aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
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

        stage ('Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            #comment shell scripts
                            echo "Test stage"
                            test -f build/$INDEX_FILE_NAME
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }
                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                            /* Install as admin:
                            args '-u root:root' */
                        }
                    }
                    steps {
                        sh '''
                            # global installatio of serve (may need admin rights):
                            # npm install -g serve
                            # local install
                            # npm install serve
                            # &: start ins the background
                            serve -s build &
                            # Wait for server to be started:
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            // HTML cannot be shown automatically because of CSP
                            // see https://www.jenkins.io/doc/book/security/configuring-content-security-policy/
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }

        }

        stage('Deploy staging') {
           agent {
             docker {
                image 'my-playwright'
                reuseNode true
                   /* Install as admin:
                   args '-u root:root' */
              }
            }

            environment {
                CI_ENVIRONMENT_URL = 'URL_TO_BE_SET'
            }

           steps {
             sh '''
                    netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --no-build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-output.json)
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    // HTML cannot be shown automatically because of CSP
                    // see https://www.jenkins.io/doc/book/security/configuring-content-security-policy/
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
        // stage('Approval') {
        //     steps {
        //         timeout(time: 1, unit: 'MINUTES') {
        //             input cancel: 'Hell No!', message: 'Do you wish to deploy to production?', ok: 'Oh Yeah!'
        //         }
                
        //     }
        // }
        


        stage('Deploy prod') {
           agent {
             docker {
                image 'my-playwright'
                reuseNode true
                   /* Install as admin:
                   args '-u root:root' */
              }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://dreamy-monstera-d95a96.netlify.app'
            }
    
           steps {
             sh '''
                netlify --version
                echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                netlify status
                netlify deploy --dir=build --prod --no-build
                npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    // HTML cannot be shown automatically because of CSP
                    // see https://www.jenkins.io/doc/book/security/configuring-content-security-policy/
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
    
}