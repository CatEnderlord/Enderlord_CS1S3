# AWS Infrastructure Project

This project deploys a complete AWS infrastructure with:
- VPC with public/private subnets
- Bastion host for secure access
- Auto-scaling web servers
- MySQL database (RDS)
- Load balancer
- Grafana monitoring
- CloudWatch alarms

## Get Started

**Read the complete guide:** [HOW_TO_USE.md](HOW_TO_USE.md)

## Quick Commands

```bash
# Deploy everything
./tf.bat apply

# Get all information
./tf.bat outputs

# Destroy everything
./tf.bat destroy
```

## What You Need

1. AWS Account with credentials
2. Terraform installed
3. AWS CLI installed
4. Git Bash (for Windows)

**See [HOW_TO_USE.md](HOW_TO_USE.md) for detailed step-by-step instructions.**
