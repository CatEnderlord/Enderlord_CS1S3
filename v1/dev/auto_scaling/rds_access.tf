# Add ASG security group to RDS ingress rules
# This is done in the auto_scaling module to avoid circular dependency
resource "aws_security_group_rule" "rds_from_asg" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.database.outputs.rds_sg_id
  source_security_group_id = aws_security_group.asg_sg.id
  description              = "MySQL from ASG instances"
}
