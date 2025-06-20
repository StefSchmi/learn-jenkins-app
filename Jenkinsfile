pipeline {
    agent any

    environment {
        INDEX_FILE_NAME = 'index.html'
    }
    stages {
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
        stage('Test') {

            steps {
                sh '''
                    echo "Test stage"
                    test -f /build/$INDEX_FILE_NAME
                '''
            }
        }
    }
}