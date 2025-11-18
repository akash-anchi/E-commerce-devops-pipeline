pipeline {
  agent any

  environment {
    DEV_REPO  = "in29mins/devops-app-dev"
    PROD_REPO = "in29mins/devops-app-prod"
    DOCKER_CRED = "dockerhub-creds"
    SSH_CRED = "ec2-ssh-creds"        // Jenkins credentials id for SSH (SSH Username with private key)
    EC2_HOST = "3.141.196.94"         // EC2 IP (no "ubuntu@" here)
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      steps {
        script {
          // Choose repo based on branch
          def repo = (env.BRANCH_NAME == 'master') ? "${PROD_REPO}" : "${DEV_REPO}"
          def tag = "${env.BUILD_NUMBER}"
          def imageName = "${repo}:${tag}"

          echo "Building image ${imageName}"

          // Login to Docker registry using credentials id
          docker.withRegistry('', DOCKER_CRED) {
            def built = docker.build(imageName)
            built.push()
            // Optionally also push 'latest' for dev or master
            if (env.BRANCH_NAME == 'dev') {
              built.push("latest")
            }
            if (env.BRANCH_NAME == 'master') {
              built.push("latest")
            }
          }
        }
      }
    }

    stage('Deploy to Prod') {
      when {
        branch 'master'
      }
      steps {
        script {
          // Use sshagent to use the SSH private key credential stored in Jenkins
          sshagent (credentials: ['ec2-ssh-creds']) {
            // Pull and restart container on remote EC2
            sh """
              ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} \\
                'docker pull ${PROD_REPO}:${env.BUILD_NUMBER} && \\
                 docker rm -f devops-app || true && \\
                 docker run -d --name devops-app -p 80:80 --restart unless-stopped ${PROD_REPO}:${env.BUILD_NUMBER}'
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline finished: SUCCESS"
    }
    failure {
      echo "Pipeline finished: FAILURE"
    }
  }
}
