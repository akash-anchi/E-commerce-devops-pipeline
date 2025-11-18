pipeline {
  agent any

  environment {
    DEV_REPO  = "in29mins/devops-app-dev"
    PROD_REPO = "in29mins/devops-app-prod"
    DOCKER_CRED = "dockerhub-creds"
    SSH_CRED = "ec2-ssh-creds"
    EC2 = "ubuntu@3.141.196.94"
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
          docker.withRegistry('', DOCKER_CRED) {
            if (env.BRANCH_NAME == 'dev') {
              IMAGE = "${DEV_REPO}:${env.BUILD_NUMBER}"
              echo "Building ${IMAGE}"
              docker.build(IMAGE).push()
            } else if (env.BRANCH_NAME == 'master') {
              IMAGE = "${PROD_REPO}:${env.BUILD_NUMBER}"
              echo "Building ${IMAGE}"
              docker.build(IMAGE).push()
            } else {
              error("Branch ${env.BRANCH_NAME} not supported")
            }
          }
        }
      }
    }

    stage('Deploy to Prod') {
      when { branch 'master' }
      steps {
        script {
          sshagent(credentials: [SSH_CRED]) {
            sh """
              ssh -o StrictHostKeyChecking=no ${EC2} '
                docker pull ${PROD_REPO}:${env.BUILD_NUMBER} || true &&
                docker stop devops-app || true &&
                docker rm devops-app || true &&
                docker run -d --name devops-app -p 80:80 --restart unless-stopped ${PROD_REPO}:${env.BUILD_NUMBER}
              '
            """
          }
        }
      }
    }
  }

  post {
    failure {
      echo "Pipeline failed on branch ${env.BRANCH_NAME}"
    }
  }
}
