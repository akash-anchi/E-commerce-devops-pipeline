pipeline {
  agent any

  environment {
    DEV_REPO  = "in29mins/devops-app-dev"
    PROD_REPO = "in29mins/devops-app-prod"
    DOCKER_CRED = "dockerhub-creds"   // Jenkins credential id for Docker Hub
    SSH_CRED = "ec2-ssh-creds"        // Jenkins credential id for SSH (SSH Username with private key)
    EC2_HOST = "3.141.196.94"         // EC2 public IP (no "ubuntu@" here)
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
          // choose the repo based on the branch
          def repo = (env.BRANCH_NAME == 'master') ? env.PROD_REPO : env.DEV_REPO
          def tag  = env.BUILD_NUMBER ?: "latest"
          def imageName = "${repo}:${tag}"

          echo "Building image ${imageName}"

          // Use env.DOCKER_CRED (credential id) when calling docker.withRegistry
          docker.withRegistry('', env.DOCKER_CRED) {
            def built = docker.build(imageName)
            built.push()
            // push 'latest' for dev or master branches as an option
            if (env.BRANCH_NAME == 'dev' || env.BRANCH_NAME == 'master') {
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
          // Use sshagent with the credential id from env.SSH_CRED
          sshagent(credentials: [env.SSH_CRED]) {
            // Single-line remote command to avoid broken strings
            def remoteImage = "${env.PROD_REPO}:${env.BUILD_NUMBER}"
            def sshCmd = "ssh -o StrictHostKeyChecking=no ubuntu@${env.EC2_HOST} " +
                         "'docker pull ${remoteImage} && docker rm -f devops-app || true && " +
                         "docker run -d --name devops-app -p 80:80 --restart unless-stopped ${remoteImage}'"
            echo "Running remote deploy: ${sshCmd}"
            sh sshCmd
          }
        }
      }
    }
  }

  post {
    success { echo "Pipeline finished: SUCCESS" }
    failure { echo "Pipeline finished: FAILURE" }
  }
}
