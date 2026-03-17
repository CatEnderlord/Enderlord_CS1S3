data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  
  tags = {
    Name = "${var.env}-nat-eip"
  }
  
  depends_on = [data.terraform_remote_state.vpc]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  
  tags = {
    Name = "${var.env}-nat-gateway"
  }
  
  depends_on = [aws_eip.nat]
}

resource "aws_route" "private_nat" {
  route_table_id         = data.terraform_remote_state.vpc.outputs.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
