#!/bin/bash
# 1. Update and install Java 21 (Required by the latest Jenkins)
sudo dnf update -y
sudo dnf install java-21-amazon-corretto-devel -y
sudo dnf install java-21-amazon-corretto-devel git -y

# 2. Add Jenkins Repo and Key
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key


# 3. Install and Start Jenkins
sudo dnf install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 4. Docker Setup
sudo dnf install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins

# 5. Trivy Security Scanner
RELEASE_VERSION=$(curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
wget https://github.com/aquasecurity/trivy/releases/download/${RELEASE_VERSION}/trivy_${RELEASE_VERSION:1}_Linux-64bit.rpm
sudo yum localinstall -y trivy_${RELEASE_VERSION:1}_Linux-64bit.rpm

# 6. Final Restart
sudo systemctl restart jenkins