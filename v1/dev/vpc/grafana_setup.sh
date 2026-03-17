#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
docker run -d -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  -e GF_SERVER_ROOT_URL=http://localhost:3000/ \
  -e GF_SERVER_SERVE_FROM_SUB_PATH=false \
  --name=grafana \
  --restart=always \
  grafana/grafana-oss
echo "Grafana ready"