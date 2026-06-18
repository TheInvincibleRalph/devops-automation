#!/bin/bash
set -euo pipefail

# Install Docker (Amazon Linux 2023)
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker

# Environment file used by the app container at deploy time
cat <<EOF > /etc/ecommerce.env
DB_HOST=${db_endpoint}
DB_PORT=3306
DB_DATABASE=${db_database}
DB_USERNAME=${db_username}
DB_PASSWORD=${app_db_password}
EOF

chmod 600 /etc/ecommerce.env
