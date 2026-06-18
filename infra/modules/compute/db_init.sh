#!/bin/bash
set -euo pipefail

# Install and start MariaDB (Amazon Linux 2023)
sudo dnf update -y
sudo dnf install -y mariadb105-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Load schema from base64 content injected by Terraform
echo '${sql_schema_b64}' | base64 -d > /tmp/ecommerceapp.sql

# Configure database, user, and schema
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
CREATE DATABASE IF NOT EXISTS ecommerceapp;
CREATE USER IF NOT EXISTS '${db_username}'@'${app_mysql_host}' IDENTIFIED BY '${app_db_password}';
GRANT ALL PRIVILEGES ON ecommerceapp.* TO '${db_username}'@'${app_mysql_host}';
FLUSH PRIVILEGES;
EOF

sudo mysql -u root -p'${db_root_password}' ecommerceapp < /tmp/ecommerceapp.sql
rm -f /tmp/ecommerceapp.sql
