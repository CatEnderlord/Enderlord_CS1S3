#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"

apply() {
    echo -e "${GREEN}Starting deployment of all modules...${NC}"
    
    # VPC (base infrastructure with bastion)
    echo -e "${YELLOW}[1/6] Deploying VPC (includes bastion)...${NC}"
    cd "$SCRIPT_DIR/vpc" || { echo -e "${RED}Failed to cd to vpc${NC}"; sleep 100; exit 1; }
    terraform init || { echo -e "${RED}VPC init failed${NC}"; sleep 100; exit 1; }
    terraform apply -auto-approve || { echo -e "${RED}VPC apply failed${NC}"; sleep 100; exit 1; }
    
    # Database
    echo -e "${YELLOW}[2/6] Deploying Database...${NC}"
    cd "$SCRIPT_DIR/database" || { echo -e "${RED}Failed to cd to database${NC}"; sleep 100; exit 1; }
    terraform init || { echo -e "${RED}Database init failed${NC}"; sleep 100; exit 1; }
    terraform apply -auto-approve || { echo -e "${RED}Database apply failed${NC}"; sleep 100; exit 1; }
    
    # NAT Gateway
    echo -e "${YELLOW}[3/6] Deploying NAT Gateway...${NC}"
    cd "$SCRIPT_DIR/nat_gateway" || { echo -e "${RED}Failed to cd to nat_gateway${NC}"; sleep 100; exit 1; }
    terraform init || { echo -e "${RED}NAT Gateway init failed${NC}"; sleep 100; exit 1; }
    terraform apply -auto-approve || { echo -e "${RED}NAT Gateway apply failed${NC}"; sleep 100; exit 1; }
    
    # Load Balancer
    echo -e "${YELLOW}[4/6] Deploying Load Balancer...${NC}"
    cd "$SCRIPT_DIR/load_balancer" || { echo -e "${RED}Failed to cd to load_balancer${NC}"; sleep 100; exit 1; }
    terraform init || { echo -e "${RED}Load Balancer init failed${NC}"; sleep 100; exit 1; }
    terraform apply -auto-approve || { echo -e "${RED}Load Balancer apply failed${NC}"; sleep 100; exit 1; }
    
    # Auto Scaling
    echo -e "${YELLOW}[5/6] Deploying Auto Scaling...${NC}"
    cd "$SCRIPT_DIR/auto_scaling" || { echo -e "${RED}Failed to cd to auto_scaling${NC}"; sleep 100; exit 1; }
    terraform init || { echo -e "${RED}Auto Scaling init failed${NC}"; sleep 100; exit 1; }
    terraform apply -auto-approve || { echo -e "${RED}Auto Scaling apply failed${NC}"; sleep 100; exit 1; }
    
    # Monitoring
    echo -e "${YELLOW}[6/6] Deploying Monitoring...${NC}"
    cd "$SCRIPT_DIR/monitoring" || { echo -e "${RED}Failed to cd to monitoring${NC}"; sleep 100; exit 1; }
    terraform init || { echo -e "${RED}Monitoring init failed${NC}"; sleep 100; exit 1; }
    terraform apply -auto-approve || { echo -e "${RED}Monitoring apply failed${NC}"; sleep 100; exit 1; }
    
    cd "$SCRIPT_DIR"
    echo -e "${GREEN}✓ All modules deployed successfully!${NC}"
    echo ""
    echo "Get your URLs:"
    echo "  ALB URL: cd load_balancer && terraform output alb_url"
    echo "  Grafana via ALB: cd load_balancer && terraform output grafana_url"
    echo "  Bastion IP: cd vpc && terraform output bastion_public_ip"
    echo ""
    echo "Closing in 10 seconds..."
    sleep 10
}

destroy() {
    echo -e "${RED}Starting destruction of all modules...${NC}"
    echo -e "${YELLOW}This will destroy all infrastructure in reverse order${NC}"
    
    # Monitoring
    echo -e "${YELLOW}[1/6] Destroying Monitoring...${NC}"
    cd "$SCRIPT_DIR/monitoring" || { echo -e "${RED}Failed to cd to monitoring${NC}"; sleep 100; exit 1; }
    terraform destroy -auto-approve || echo -e "${RED}Warning: Monitoring destroy had issues${NC}"
    
    # Auto Scaling
    echo -e "${YELLOW}[2/6] Destroying Auto Scaling...${NC}"
    cd "$SCRIPT_DIR/auto_scaling" || { echo -e "${RED}Failed to cd to auto_scaling${NC}"; sleep 100; exit 1; }
    terraform destroy -auto-approve || echo -e "${RED}Warning: Auto Scaling destroy had issues${NC}"
    
    # Load Balancer
    echo -e "${YELLOW}[3/6] Destroying Load Balancer...${NC}"
    cd "$SCRIPT_DIR/load_balancer" || { echo -e "${RED}Failed to cd to load_balancer${NC}"; sleep 100; exit 1; }
    terraform destroy -auto-approve || echo -e "${RED}Warning: Load Balancer destroy had issues${NC}"
    
    # NAT Gateway
    echo -e "${YELLOW}[4/6] Destroying NAT Gateway...${NC}"
    cd "$SCRIPT_DIR/nat_gateway" || { echo -e "${RED}Failed to cd to nat_gateway${NC}"; sleep 100; exit 1; }
    terraform destroy -auto-approve || echo -e "${RED}Warning: NAT Gateway destroy had issues${NC}"
    
    # Database
    echo -e "${YELLOW}[5/6] Destroying Database...${NC}"
    cd "$SCRIPT_DIR/database" || { echo -e "${RED}Failed to cd to database${NC}"; sleep 100; exit 1; }
    terraform destroy -auto-approve || echo -e "${RED}Warning: Database destroy had issues${NC}"
    
    # VPC (includes bastion)
    echo -e "${YELLOW}[6/6] Destroying VPC (includes bastion)...${NC}"
    cd "$SCRIPT_DIR/vpc" || { echo -e "${RED}Failed to cd to vpc${NC}"; sleep 100; exit 1; }
    terraform destroy -auto-approve || echo -e "${RED}Warning: VPC destroy had issues${NC}"
    
    cd "$SCRIPT_DIR"
    echo -e "${GREEN}✓ All modules destroyed!${NC}"
    echo -e "${YELLOW}Note: Check AWS Console to verify all resources are deleted${NC}"
    echo ""
    echo "Closing in 10 seconds..."
    sleep 10
}

plan() {
    echo -e "${GREEN}Planning all modules...${NC}"
    
    cd "$SCRIPT_DIR/vpc" && terraform init && terraform plan || { echo -e "${RED}VPC plan failed${NC}"; sleep 100; exit 1; }
    cd "$SCRIPT_DIR/database" && terraform init && terraform plan || { echo -e "${RED}Database plan failed${NC}"; sleep 100; exit 1; }
    cd "$SCRIPT_DIR/nat_gateway" && terraform init && terraform plan || { echo -e "${RED}NAT Gateway plan failed${NC}"; sleep 100; exit 1; }
    cd "$SCRIPT_DIR/load_balancer" && terraform init && terraform plan || { echo -e "${RED}Load Balancer plan failed${NC}"; sleep 100; exit 1; }
    cd "$SCRIPT_DIR/auto_scaling" && terraform init && terraform plan || { echo -e "${RED}Auto Scaling plan failed${NC}"; sleep 100; exit 1; }
    cd "$SCRIPT_DIR/monitoring" && terraform init && terraform plan || { echo -e "${RED}Monitoring plan failed${NC}"; sleep 100; exit 1; }
    
    cd "$SCRIPT_DIR"
    echo -e "${GREEN}✓ Planning complete${NC}"
    echo ""
    echo "Closing in 10 seconds..."
    sleep 10
}

init() {
    echo -e "${GREEN}Initializing all modules...${NC}"
    
    cd "$SCRIPT_DIR/vpc" && terraform init
    cd "$SCRIPT_DIR/database" && terraform init
    cd "$SCRIPT_DIR/nat_gateway" && terraform init
    cd "$SCRIPT_DIR/load_balancer" && terraform init
    cd "$SCRIPT_DIR/auto_scaling" && terraform init
    cd "$SCRIPT_DIR/monitoring" && terraform init
    
    cd "$SCRIPT_DIR"
    echo -e "${GREEN}✓ All modules initialized${NC}"
}

status() {
    echo -e "${GREEN}Checking status of all modules...${NC}"
    echo ""
    
    for module in vpc database nat_gateway load_balancer auto_scaling monitoring; do
        echo -e "${YELLOW}=== $module ===${NC}"
        if [ -f "$SCRIPT_DIR/$module/terraform.tfstate" ]; then
            cd "$SCRIPT_DIR/$module" || { echo -e "${RED}Failed to cd to $module${NC}"; sleep 100; exit 1; }
            terraform show -no-color | head -20 || { echo -e "${RED}Failed to show $module state${NC}"; sleep 100; exit 1; }
            echo ""
        else
            echo "No state file found"
            echo ""
        fi
    done
    
    cd "$SCRIPT_DIR"
    echo ""
    echo "Closing in 10 seconds..."
    sleep 10
}

outputs() {
    echo -e "${GREEN}Getting outputs from all modules...${NC}"
    echo ""
    
    echo -e "${YELLOW}=== VPC Outputs (includes bastion) ===${NC}"
    cd "$SCRIPT_DIR/vpc" && terraform output 2>/dev/null || { echo -e "${RED}Failed to get VPC outputs${NC}"; sleep 100; exit 1; }
    echo ""
    
    echo -e "${YELLOW}=== Database Outputs ===${NC}"
    cd "$SCRIPT_DIR/database" && terraform output 2>/dev/null || echo "No outputs or module not deployed"
    echo ""
    
    echo -e "${YELLOW}=== NAT Gateway Outputs ===${NC}"
    cd "$SCRIPT_DIR/nat_gateway" && terraform output 2>/dev/null || echo "No outputs or module not deployed"
    echo ""
    
    echo -e "${YELLOW}=== Load Balancer Outputs ===${NC}"
    cd "$SCRIPT_DIR/load_balancer" && terraform output 2>/dev/null || echo "No outputs or module not deployed"
    echo ""
    
    echo -e "${YELLOW}=== Auto Scaling Outputs ===${NC}"
    cd "$SCRIPT_DIR/auto_scaling" && terraform output 2>/dev/null || echo "No outputs or module not deployed"
    echo ""
    
    echo -e "${YELLOW}=== Monitoring Outputs ===${NC}"
    cd "$SCRIPT_DIR/monitoring" && terraform output 2>/dev/null || echo "No outputs or module not deployed"
    echo ""
    
    cd "$SCRIPT_DIR"
    echo ""
    echo "Closing in 10 seconds..."
    sleep 10
}

help() {
    echo "Usage: ./tf.sh [command]"
    echo ""
    echo "Commands:"
    echo "  apply     - Deploy all modules in correct order"
    echo "  destroy   - Destroy all modules in reverse order"
    echo "  plan      - Plan all modules"
    echo "  init      - Initialize all modules"
    echo "  status    - Show status of all modules"
    echo "  outputs   - Show outputs from all modules"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./tf.sh apply      # Deploy everything"
    echo "  ./tf.sh destroy    # Destroy everything"
    echo "  ./tf.sh outputs    # Get all URLs and info"
}

case "$1" in
    "apply")
        apply
        ;;
    "destroy")
        destroy
        ;;
    "plan")
        plan
        ;;
    "init")
        init
        ;;
    "status")
        status
        ;;
    "outputs")
        outputs
        ;;
    "help")
        help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        help
        exit 1
        ;;
esac