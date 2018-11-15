FROM jenkins:latest

# ECS Docker version -> 18.06.1-ce
# Suppress apt installation warnings 
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

# Used to set the docker group ID
# Set to 497 by default, which is the group ID by AWS Linux ECS Instance
ARG DOCKER_GID=497

# Create Docker Group with GID
# Set default value of 497 if DOCKER_ID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-497} docker

# Use to control Docker and Docker compose versions installed
# As of February 2016, AWS Linux ECS only supports Docker 1.9.1
ARG DOCKER_ENGINE=18.06.0~ce~3-0~debian
ARG DOCKER_COMPOSE=1.23.1

# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https \   
                    ca-certificates \
                    software-properties-common \
                    curl \
                    python-dev \
                    python-setuptools \
                    gcc \
                    make \
                    libssl-dev \
    -y && easy_install pip

# Setup repository and install Docker engine
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
    apt-get update -y && \
    apt-get install docker-ce=${DOCKER_ENGINE:-18.06.0~ce~3-0~debian} -y && \
    usermod -aG docker jenkins && \
    usermod -aG users jenkins

# Install Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE:-1.23.1}/docker-compose-$(uname -s)-$(uname -m) \
        -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install ansible and boto packages
RUN pip install ansible boto boto3

# # Change to jenkins user
# USER jenkins

# COPY plugins.txt /usr/share/jenkins/plugins.txt
# RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# USER root