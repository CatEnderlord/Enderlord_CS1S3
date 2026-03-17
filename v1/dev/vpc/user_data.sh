#!/bin/bash
exec > /var/log/user-data.log 2>&1

echo "Starting setup at $(date)"

# Install Docker
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Start Grafana
docker run -d -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  --name=grafana \
  --restart=always \
  grafana/grafana-oss

echo "Grafana started at $(date)"
docker ps

echo "Setup complete at $(date)"
