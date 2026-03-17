# How to Use This AWS Infrastructure

This guide shows you how to deploy, test, and destroy AWS infrastructure step by step.

---

## Prerequisites

1. **AWS Account** - You need an AWS account with credentials configured
2. **AWS CLI** - Install from https://aws.amazon.com/cli/
3. **Terraform** - Install from https://www.terraform.io/downloads
4. **Git Bash** - For Windows users (comes with Git for Windows)

---

## Step 1: Configure AWS Credentials

Open PowerShell and run:

```powershell
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `eu-central-1`
- Default output format: `json`

---

## Step 2: Setup Configuration Files

You need to create configuration files in 3 folders.

### 2.1 VPC Configuration

Create file: `vpc/terraform.tfvars`

```hcl
admin_ip    = "YOUR_IP_HERE/32"
db_password = "ADMIN123"
```

**How to get YOUR_IP_HERE:**
- Go to https://whatismyip.com
- Copy your IP address
- Example: If your IP is `145.93.49.206`, use `145.93.49.206/32`

### 2.2 Database Configuration

Create file: `database/terraform.tfvars`

```hcl
db_password = "ADMIN123"
```

### 2.3 Auto Scaling Configuration

Create file: `auto_scaling/terraform.tfvars`

```hcl
admin_ip    = "YOUR_IP_HERE/32"
db_password = "ADMIN123"
```

---

## Step 3: Deploy Everything

Open Git Bash in the `dev` folder and run:

```bash
./tf.bat apply
```

This will:
- Deploy VPC, subnets, and bastion host
- Deploy database (RDS MySQL)
- Deploy NAT Gateway
- Deploy Load Balancer
- Deploy Auto Scaling Group (web servers)
- Deploy Monitoring (CloudWatch)
- Deploy Subnet configuration

**Wait time:** 10-15 minutes

---

## Step 4: Get Important Information

After deployment completes, get your infrastructure details:

### 4.1 Get Bastion IP Address

```bash
cd vpc
terraform output bastion_public_ip
```

Copy this IP address (example: `3.120.111.21`)

### 4.2 Get Grafana Private IP

```bash
terraform output grafana_private_ip
```

Copy this IP address (example: `10.0.2.196`)

### 4.3 Get Load Balancer URL

```bash
cd ../load_balancer
terraform output alb_url
```

Copy this URL (example: `http://dev-alb-1700900187.eu-central-1.elb.amazonaws.com`)

---

## Step 5: Test Your Infrastructure

### Test 1: Access Your Web Application

Open your browser and go to the Load Balancer URL from Step 4.3.

You should see a web page showing instance information.

### Test 2: Access Grafana Monitoring

#### Step 2a: Fix SSH Key (First Time Only)

Open PowerShell and run:

```powershell
Get-Content $env:USERPROFILE\.ssh\dev-bastion-key.pem -Raw | Out-File -Encoding ASCII -NoNewline $env:USERPROFILE\.ssh\dev-bastion-key-fixed.pem

icacls $env:USERPROFILE\.ssh\dev-bastion-key-fixed.pem /inheritance:r /grant:r "$($env:USERNAME):R"
```

#### Step 2b: Create SSH Tunnel

Replace `BASTION_IP` with your bastion IP from Step 4.1
Replace `GRAFANA_IP` with your Grafana IP from Step 4.2

```powershell
ssh -i $env:USERPROFILE\.ssh\dev-bastion-key-fixed.pem -L 3000:GRAFANA_IP:3000 ec2-user@BASTION_IP
```

**Example:**
```powershell
ssh -i $env:USERPROFILE\.ssh\dev-bastion-key-fixed.pem -L 3000:10.0.2.196:3000 ec2-user@3.120.111.21
```

**Keep this window open!**

#### Step 2c: Open Grafana

Open your browser and go to:

```
http://localhost:3000
```

Login:
- Username: `admin`
- Password: `admin`

---

## Step 6: Destroy Everything

When you're done testing, destroy all resources to avoid AWS charges.

Open Git Bash in the `dev` folder and run:

```bash
./tf.bat destroy
```

This will delete everything in reverse order.

**Wait time:** 10-15 minutes

---

## Quick Command Reference

### Deploy Infrastructure
```bash
cd C:\Users\costi\Desktop\Codes\Fonty's File\Fonty's Projects - Semester3\A-Main\Enderlord_CS1S3\v1\dev
./tf.bat apply
```

### Get All Outputs
```bash
./tf.bat outputs
```

### Check Status
```bash
./tf.bat status
```

### Destroy Infrastructure
```bash
./tf.bat destroy
```

### Access Grafana (PowerShell)
```powershell
ssh -i $env:USERPROFILE\.ssh\dev-bastion-key-fixed.pem -L 3000:10.0.2.196:3000 ec2-user@3.120.111.21
```

Then open: http://localhost:3000

---

## Troubleshooting

### Problem: "terraform: command not found"

**Solution:** Install Terraform from https://www.terraform.io/downloads

### Problem: "AWS credentials not found"

**Solution:** Run `aws configure` and enter your credentials

### Problem: "SSH connection timed out"

**Solution:** 
1. Check your bastion IP is correct: `cd vpc && terraform output bastion_public_ip`
2. Wait 2-3 minutes after deployment for the instance to start

### Problem: "SSH key invalid format"

**Solution:** Run the key fix command from Step 5, Test 2a

### Problem: "Can't access Load Balancer URL"

**Solution:**
1. Wait 5 minutes after deployment for health checks to pass
2. Check if instances are healthy: Go to AWS Console → EC2 → Target Groups

### Problem: "Grafana shows 502 Bad Gateway"

**Solution:** Wait 3-5 minutes for Grafana to start, then refresh the page

---

## What Gets Deployed

- **VPC** - Virtual network with public and private subnets
- **Bastion Host** - Jump server to access private instances (in public subnet)
- **Grafana** - Monitoring dashboard (in private subnet)
- **RDS MySQL** - Database (in private subnet)
- **NAT Gateway** - Allows private instances to access internet
- **Load Balancer** - Distributes traffic to web servers
- **Auto Scaling Group** - 2-4 web server instances (in private subnets)
- **CloudWatch** - Monitoring and alarms

---

## Cost Warning

Running this infrastructure costs approximately:
- **NAT Gateway:** ~$32/month (~$0.045/hour)
- **EC2 Instances:** ~$15/month (t3.micro)
- **RDS Database:** ~$15/month (db.t3.micro)
- **Load Balancer:** ~$20/month

**Total:** ~$82/month if left running 24/7

**Always destroy resources when not in use!**

---

## Security Notes

- Bastion host is in public subnet (accessible from your IP only)
- All other resources are in private subnets (not directly accessible from internet)
- SSH access is restricted to your IP address
- Database password is `ADMIN123` (change this for production!)

---

## Need Help?

1. Check AWS Console to see if resources are created
2. Check Terraform output for error messages
3. Make sure your IP address is correct in terraform.tfvars files
4. Make sure AWS credentials are configured correctly
