pipeline {
    agent any

    environment {
        INDEX_FILE_NAME = 'index.html'
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
                }
            }

        }
        
    }
    post {
        always {
            junit 'jest-results/junit.xml'
            // HTML cannot be shown automatically because of CSP
            // see https://www.jenkins.io/doc/book/security/configuring-content-security-policy/
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}