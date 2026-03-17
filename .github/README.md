# GitHub Actions Setup

This repository includes automated CI/CD pipelines for the AWS infrastructure.

## Workflows

### 1. Terraform Validate (`terraform-validate.yml`)
- **Trigger:** Pull requests that modify `.tf` files
- **Purpose:** Validates Terraform syntax and formatting
- **Actions:** Format check, init, and validate all modules

### 2. Deploy to Dev (`deploy-dev.yml`)
- **Trigger:** Push to `main` branch or manual dispatch
- **Purpose:** Deploys infrastructure to AWS dev environment
- **Actions:** Deploys all modules in correct order

### 3. Destroy Infrastructure (`destroy.yml`)
- **Trigger:** Manual dispatch only
- **Purpose:** Destroys all AWS resources to avoid costs
- **Safety:** Requires typing "destroy" to confirm

## Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

### AWS Credentials
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key

### Infrastructure Configuration
- `ADMIN_IP` - Your IP address (e.g., `203.0.113.0/32`)
- `DB_PASSWORD` - Database password (e.g., `SecurePassword123!`)
- `ALERT_EMAIL` - Email for CloudWatch alerts (optional)

## Usage

### Deploy Infrastructure
1. Push changes to `main` branch
2. GitHub Actions will automatically deploy
3. Check the Actions tab for deployment status
4. View outputs in the workflow summary

### Destroy Infrastructure
1. Go to **Actions → Destroy Infrastructure**
2. Click **Run workflow**
3. Type `destroy` in the confirmation field
4. Click **Run workflow**

### Manual Deploy
1. Go to **Actions → Deploy to Dev**
2. Click **Run workflow**
3. Select branch and click **Run workflow**

## Environment Protection

The `dev` environment is configured with protection rules:
- Only `main` branch can deploy
- Manual approval may be required (configure in Settings → Environments)

## Cost Management

- The destroy workflow helps avoid AWS charges
- Set up billing alerts in AWS Console
- Monitor costs regularly

## Troubleshooting

### Common Issues
- **Invalid credentials:** Check AWS secrets are correct
- **Permission denied:** Ensure AWS user has required permissions
- **Terraform state conflicts:** May need to manually resolve state issues

### Required AWS Permissions
Your AWS user needs these policies:
- `AmazonEC2FullAccess`
- `AmazonRDSFullAccess`
- `AmazonVPCFullAccess`
- `ElasticLoadBalancingFullAccess`
- `AutoScalingFullAccess`
- `CloudWatchFullAccess`
- `IAMFullAccess`