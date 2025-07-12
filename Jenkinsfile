pipeline {
    agent any

    environment {
        INDEX_FILE_NAME = 'index.html'
        NETLIFY_SITE_ID = 'a09236b1-d9df-4f0e-a43e-7fe52ebaafc9'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }
    stages {
        // THis is build step
        /*
            Everything will explained.
         */
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
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
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
                            npm install serve
                            # &: start ins teh background
                            node_modules/.bin/serve -s build &
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
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --no-build
                '''
            }
        }

        stage('Deploy prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod --no-build
                '''
            }
        }

        stage('Prod E2E') {
           agent {
             docker {
                image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
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
                npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    // HTML cannot be shown automatically because of CSP
                    // see https://www.jenkins.io/doc/book/security/configuring-content-security-policy/
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
    
}