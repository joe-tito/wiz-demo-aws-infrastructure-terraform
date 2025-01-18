module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wiz-demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
}


# resource "aws_vpc" "this" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "public" {
#   vpc_id     = aws_vpc.this.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "Public"
#   }
# }

# resource "aws_subnet" "private" {
#   vpc_id     = aws_vpc.this.id
#   cidr_block = "10.0.101.0/24"

#   tags = {
#     Name = "Private"
#   }
# }


# # Internet Gateway for the public subnet
# resource "aws_internet_gateway" "this" {
#   tags = {
#     Name = "Wiz Demo IGW"
#   }
#   vpc_id = aws_vpc.this.id
# }

# # NAT Gateway for the public subnet
# resource "aws_eip" "this" {
#   domain                    = "vpc"
#   associate_with_private_ip = "10.0.0.5"
#   depends_on                = [aws_internet_gateway.this]
# }
# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.this.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "Wiz Demo NGW"
#   }
#   depends_on = [aws_eip.this]
# }

# # Route tables for the subnets
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.this.id
#   tags = {
#     Name = "Wiz Demo Public Route Table"
#   }
# }
# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.this.id
#   tags = {
#     Name = "Wiz Demo Private Route Table"
#   }
# }

# # Route the public subnet traffic through the Internet Gateway
# resource "aws_route" "public_igw_route" {
#   route_table_id         = aws_route_table.public_route_table.id
#   gateway_id             = aws_internet_gateway.this.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# # Route NAT Gateway
# resource "aws_route" "nat_ngw_route" {
#   route_table_id         = aws_route_table.private_route_table.id
#   nat_gateway_id         = aws_nat_gateway.this.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# # Associate the newly created route tables to the subnets
# resource "aws_route_table_association" "public-route-1-association" {
#   route_table_id = aws_route_table.public_route_table.id
#   subnet_id      = aws_subnet.public.id
# }

# resource "aws_route_table_association" "private-route-1-association" {
#   route_table_id = aws_route_table.private_route_table.id
#   subnet_id      = aws_subnet.private.id
# }
