#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker

# Create the environment file with the dynamic variables injected by Terraform
cat <<EOF > /etc/ecommerce.env
DB_CONNECTION=pgsql
DB_HOST=${db_endpoint}
DB_PORT=5432
DB_DATABASE=ecommerce
DB_USERNAME=postgres
DB_PASSWORD=${db_password} 
EOF

# Secure the file so only root can read it
chmod 600 /etc/ecommerce.env