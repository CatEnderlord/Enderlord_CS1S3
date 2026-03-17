#!/bin/bash
set -e

# Update system
yum update -y

# Install Apache web server
yum install -y httpd mysql

# Start Apache
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AVAILABILITY_ZONE=$(ec2-metadata --availability-zone | cut -d " " -f 2)
PRIVATE_IP=$(ec2-metadata --local-ipv4 | cut -d " " -f 2)

# Create a simple web page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>App Server - ${env}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #FF9900; }
        .info { background: #232F3E; color: white; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .status { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS Auto Scaling Application</h1>
        <p class="status">✓ Server is running</p>
        
        <div class="info">
            <h3>Instance Information:</h3>
            <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
            <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
            <p><strong>Private IP:</strong> $PRIVATE_IP</p>
            <p><strong>Environment:</strong> ${env}</p>
        </div>
        
        <div class="info">
            <h3>Database Connection:</h3>
            <p><strong>RDS Endpoint:</strong> ${rds_endpoint}</p>
            <p><strong>Port:</strong> ${rds_port}</p>
            <p><strong>Username:</strong> ${db_username}</p>
        </div>
        
        <p><em>This server is part of an Auto Scaling Group behind an Application Load Balancer</em></p>
    </div>
</body>
</html>
EOF

# Test database connectivity (background task)
(
  sleep 30
  if mysql -h ${rds_endpoint} -P ${rds_port} -u ${db_username} -p'${db_password}' -e "SELECT 1" 2>/dev/null; then
    sed -i 's|</body>|<div class="info"><p style="color: green;">✓ Database connection successful</p></div></body>|' /var/www/html/index.html
  else
    sed -i 's|</body>|<div class="info"><p style="color: red;">✗ Database connection failed</p></div></body>|' /var/www/html/index.html
  fi
) &

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'CWCONFIG'
{
  "metrics": {
    "namespace": "CustomApp",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPUUsageIdle", "unit": "Percent"},
          {"name": "cpu_usage_user", "rename": "CPUUsageUser", "unit": "Percent"},
          {"name": "cpu_usage_system", "rename": "CPUUsageSystem", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MemoryUtilization", "unit": "Percent"},
          {"name": "mem_available", "rename": "MemoryAvailable", "unit": "Bytes"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DiskUtilization", "unit": "Percent"},
          {"name": "free", "rename": "DiskFree", "unit": "Bytes"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      },
      "netstat": {
        "measurement": [
          {"name": "tcp_established", "rename": "TCPConnections", "unit": "Count"}
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/dev/application",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CWCONFIG

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

echo "Web server setup complete!"
