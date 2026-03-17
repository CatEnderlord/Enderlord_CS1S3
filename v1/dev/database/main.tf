data "terraform_remote_state" "vpc" {
    backend = "local"
    config = {
        path = "../vpc/terraform.tfstate"
    }
}

resource "aws_route53_zone" "private" {
  name = "internal.${var.env}.local"
  
  vpc {
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  }

  tags = {
    Name = "${var.env}-private-zone"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-db-subnet-group-public"
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  tags = {
    Name = "${var.env}-db-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "${var.env}-rds-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-rds-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Separate ingress rules to avoid circular dependencies
resource "aws_security_group_rule" "rds_from_ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = data.terraform_remote_state.vpc.outputs.ec2_sg_id
  description              = "MySQL from EC2 app server"
}

resource "aws_security_group_rule" "rds_from_grafana" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = data.terraform_remote_state.vpc.outputs.grafana_sg_id
  description              = "MySQL from Grafana server"
}

resource "aws_security_group_rule" "rds_from_admin" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = [var.admin_ip]
  description       = "TEMPORARY: Direct MySQL access for testing"
}

resource "aws_db_instance" "main" {
  identifier = "${var.env}-rds"
  engine     = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 10
  
  db_name  = "appdb"
  username = var.db_username
  password = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
  storage_encrypted      = true
  multi_az               = false
  backup_retention_period = 0
  
  skip_final_snapshot = true
  
  tags = {
    Name = "${var.env}-rds"
  }
}

resource "aws_route53_record" "rds" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.internal.${var.env}.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.main.address]

  depends_on = [aws_db_instance.main]
}
