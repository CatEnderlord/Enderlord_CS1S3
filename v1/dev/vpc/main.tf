resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_support   = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = {
        Name = "${var.env}-main"
    }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env}-private-${count.index + 1}"
    Tier = "private"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + 101)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${count.index + 1}"
    Tier = "public"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.env}-ec2-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "grafana_sg" {
  name   = "${var.env}-grafana-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Grafana"
    from_port   = var.grafana_port
    to_port     = var.grafana_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  monitoring             = true

  root_block_device {
    encrypted    = true
    volume_type  = "gp3"
  }

  tags = {
    Name = "${var.env}-app-server"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_iam_role" "grafana_role" {
  name = "${var.env}-grafana-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_read" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "rds_read" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_instance_profile" "grafana_profile" {
  name = "${var.env}-grafana-profile"
  role = aws_iam_role.grafana_role.name
}

resource "aws_instance" "grafana" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.grafana_profile.name
  monitoring             = true

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              
              # Create Grafana provisioning directories
              mkdir -p /opt/grafana/provisioning/datasources
              mkdir -p /opt/grafana/provisioning/dashboards
              
              # Get RDS endpoint from database module
              RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier dev-rds --region eu-central-1 --query 'DBInstances[0].Endpoint.Address' --output text)
              
              # Create datasources config
              cat > /opt/grafana/provisioning/datasources/datasources.yml << 'EOL'
apiVersion: 1
datasources:
  - name: MySQL
    type: mysql
    access: proxy
    url: $RDS_ENDPOINT:3306
    database: appdb
    user: admin
    secureJsonData:
      password: Enderlord123!
    isDefault: true
  - name: CloudWatch
    type: cloudwatch
    access: proxy
    jsonData:
      authType: default
      defaultRegion: eu-central-1
EOL
              
              # Replace RDS_ENDPOINT in datasources config
              sed -i "s/\$RDS_ENDPOINT/$RDS_ENDPOINT/g" /opt/grafana/provisioning/datasources/datasources.yml
              
              # Create dashboards config
              cat > /opt/grafana/provisioning/dashboards/dashboards.yml << 'EOL'
apiVersion: 1
providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
EOL
              
              # Create MySQL dashboard
              mkdir -p /opt/grafana/dashboards
              cat > /opt/grafana/dashboards/mysql-dashboard.json << 'EOL'
{
  "id": null,
  "title": "MySQL Database Monitoring",
  "tags": ["mysql"],
  "timezone": "browser",
  "panels": [
    {
      "id": 1,
      "title": "Database Connections",
      "type": "stat",
      "targets": [
        {
          "rawSql": "SHOW STATUS LIKE 'Threads_connected'",
          "datasource": {
            "type": "mysql",
            "uid": "mysql"
          }
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
    },
    {
      "id": 2,
      "title": "RDS CPU Utilization",
      "type": "timeseries",
      "targets": [
        {
          "namespace": "AWS/RDS",
          "metricName": "CPUUtilization",
          "dimensions": {"DBInstanceIdentifier": "dev-rds"},
          "datasource": {
            "type": "cloudwatch",
            "uid": "cloudwatch"
          }
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
    }
  ],
  "time": {"from": "now-1h", "to": "now"},
  "refresh": "5s",
  "version": 1
}
EOL
              
              # Run Grafana with provisioning
              docker run -d \
                -p 3000:3000 \
                -v /opt/grafana/provisioning:/etc/grafana/provisioning \
                -v /opt/grafana/dashboards:/var/lib/grafana/dashboards \
                -e GF_SECURITY_ADMIN_PASSWORD=admin \
                --name=grafana \
                grafana/grafana-oss
              
              # Wait for RDS to be ready and insert test data
              sleep 60
              yum install mysql -y
              mysql -h $RDS_ENDPOINT -u admin -pEnderlord123! -e "USE appdb; CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP); INSERT IGNORE INTO users (name) VALUES ('John'), ('Jane'), ('Bob'), ('Alice'), ('Charlie'); CREATE TABLE IF NOT EXISTS orders (id INT AUTO_INCREMENT PRIMARY KEY, user_id INT, amount DECIMAL(10,2), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP); INSERT IGNORE INTO orders (user_id, amount) VALUES (1, 99.99), (2, 149.50), (3, 75.25), (1, 200.00), (4, 50.75);"
              EOF

  tags = {
    Name = "${var.env}-grafana-server"
  }
}