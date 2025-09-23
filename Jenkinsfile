pipeline {

    agent any



    environment {

        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'

        DOCKER_IMAGE_NAME        = 'abhaydocker732/internship-project'

        EC2_SERVER_IP          = '13.200.139.183' // Make sure this IP is correct!

        EC2_SSH_KEY_ID         = 'ec2-ssh-key'

    }



    stages {

        stage('Checkout') {

            steps {

                checkout scm

            }

        }



        stage('Build Docker Image') {

            steps {

                sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."

            }

        }



        stage('Login to Docker Hub') {

            steps {

                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {

                    sh "echo \$PASSWORD | docker login -u \$USERNAME --password-stdin"

                }

            }

        }



        stage('Push Docker Image') {

            steps {

                sh "docker push ${env.DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"

                sh "docker tag ${env.DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${env.DOCKER_IMAGE_NAME}:latest"

                sh "docker push ${env.DOCKER_IMAGE_NAME}:latest"

            }

        }



        stage('Deploy to EC2') {
            steps {
                sshagent([env.EC2_SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${env.EC2_SERVER_IP} '
                            # Use sudo to create the directory, then set the ubuntu user as the owner
                            sudo mkdir -p /home/ubuntu/app &&
                            sudo chown -R ubuntu:ubuntu /home/ubuntu/app &&
                            
                            # Now, cd into the directory as the ubuntu user
                            cd /home/ubuntu/app &&
                            
                            # Clone the repo if the directory is empty, otherwise pull the latest changes
                            if [ ! -d .git ]; then
                                git clone https://github.com/githubabhay2003/internship-cloud-project.git .
                            else
                                git pull
                            fi &&
                            
                            # Use Docker Compose to pull the latest image and restart the service
                            docker compose pull &&
                            docker compose up -d
                        '
                    """
                }
            }
        }

    }

    

    post {

        always {

            sh "docker logout"

        }

    }

}
