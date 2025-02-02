#Install docker on Amazon Linux VM
yum install docker -y
service docker start
service docker status
chkconfig docker on
usermod -aG docker ec2-user


#docker commands
docker version
docker info

#docker ps 
docker images


============================================
# Use an official base image
FROM ubuntu:20.04


# Update package list and install telnet, curl, and openssl
RUN apt-get update && \
    apt-get install -y curl openssl 

# Default command
CMD ["/bin/bash"]
================

# Use the Amazon Linux base image
FROM amazonlinux:2

# Update the system and install necessary packages
RUN yum update -y && \
    yum install -y git tar wget && \
    amazon-linux-extras install java-openjdk11 -y && \
    yum clean all

# Set up Maven
RUN cd /opt && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz && \
    tar xvf apache-maven-3.9.9-bin.tar.gz && \
    rm apache-maven-3.9.9-bin.tar.gz && \
    echo "export M2_HOME=/opt/apache-maven-3.9.9" >> /root/.bash_profile && \
    echo "export M2=\$M2_HOME/bin" >> /root/.bash_profile && \
    echo "export PATH=\$M2:\$PATH" >> /root/.bash_profile

# Source the .bash_profile to load the environment variables
RUN source /root/.bash_profile

=====================================
# Use the Amazon Linux base image
FROM amazonlinux:2

# Update the system and install necessary packages
RUN yum update -y && \
    yum install -y git tar wget unzip python3 python3-pip && \
    amazon-linux-extras install java-openjdk11 -y && \
    yum clean all

# Set up Maven
RUN cd /opt && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz && \
    tar xvf apache-maven-3.9.4-bin.tar.gz && \
    rm apache-maven-3.9.4-bin.tar.gz && \
    echo "export M2_HOME=/opt/apache-maven-3.9.4" >> /root/.bashrc && \
    echo "export M2=\$M2_HOME/bin" >> /root/.bashrc && \
    echo "export PATH=\$M2:\$PATH" >> /root/.bashrc

# Install Terraform
RUN cd /opt && \
    wget https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip && \
    unzip terraform_1.0.7_linux_amd64.zip && \
    rm terraform_1.0.7_linux_amd64.zip && \
    mv terraform /usr/local/bin/

# Install kubectl
RUN cd /usr/local/bin && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl


# Set environment variables for the current shell session
ENV M2_HOME=/opt/apache-maven-3.9.4
ENV M2=$M2_HOME/bin
ENV PATH=$M2:/usr/local/bin:$PATH
