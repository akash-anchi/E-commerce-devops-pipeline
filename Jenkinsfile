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
              IMAGE = "${PROD_REPO}:${env.BU_
