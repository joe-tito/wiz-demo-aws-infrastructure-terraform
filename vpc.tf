# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "wiz-demo"
#   cidr = "10.0.0.0/16"

#   azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   private_subnets = ["10.0.1.0/24"]
#   public_subnets  = ["10.0.101.0/24"]

#   #   enable_nat_gateway = true
#   #   enable_vpn_gateway = true
# }


resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.101.0/24"

  tags = {
    Name = "Private"
  }
}
