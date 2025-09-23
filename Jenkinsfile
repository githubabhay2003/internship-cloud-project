pipeline {

    agent any



    environment {

        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'

        DOCKER_IMAGE_NAME        = 'abhaydocker732/internship-project' // Using your DockerHub username and a new image name

        EC2_SERVER_IP          = '52.66.185.145'

        EC2_SSH_KEY_ID         = 'ec2-ssh-key'

    }



    stages {

        stage('Checkout') {

            steps {

                // Get the latest code from our GitHub repository

                checkout scm

            }

        }



        stage('Build Docker Image') {

            steps {

                // Build a new Docker image using our Dockerfile

                sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."

            }

        }



        stage('Login to Docker Hub') {

            steps {

                // Securely log in to Docker Hub using credentials stored in Jenkins

                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {

                    sh "echo \$PASSWORD | docker login -u \$USERNAME --password-stdin"

                }

            }

        }



        stage('Push Docker Image') {

            steps {

                // Push the newly built image to Docker Hub

                sh "docker push ${env.DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"



                // Also tag this as the 'latest' image and push

                sh "docker tag ${env.DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${env.DOCKER_IMAGE_NAME}:latest"

                sh "docker push ${env.DOCKER_IMAGE_NAME}:latest"

            }

        }



        stage('Deploy to EC2') {

            steps {

                // Use the SSH Agent plugin to securely connect to our EC2 instance

                sshagent([env.EC2_SSH_KEY_ID]) {

                    sh """

                        ssh -o StrictHostKeyChecking=no ubuntu@${env.EC2_SERVER_IP} '

                            cd /home/ubuntu/app &&

                            echo "DOCKER_IMAGE=${env.DOCKER_IMAGE_NAME}:latest" > .env &&

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

            // Clean up by logging out of Docker Hub

            sh "docker logout"

        }

    }

}
