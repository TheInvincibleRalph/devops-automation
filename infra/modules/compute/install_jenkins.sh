#!/bin/bash
set -euo pipefail

# 1. Update and install Java 21 (required by latest Jenkins)
sudo dnf update -y
sudo dnf install -y java-21-amazon-corretto-devel git awscli

# 2. Add Jenkins repo and key
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# 3. Install and start Jenkins
sudo dnf install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 4. Docker setup
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins

# 5. Trivy security scanner
RELEASE_VERSION=$(curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
wget "https://github.com/aquasecurity/trivy/releases/download/${RELEASE_VERSION}/trivy_${RELEASE_VERSION:1}_Linux-64bit.rpm"
sudo dnf localinstall -y "trivy_${RELEASE_VERSION:1}_Linux-64bit.rpm"

# 6. Final restart
sudo systemctl restart jenkins
