########################
# VPC
########################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wiz-demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  public_subnet_tags = {
    kubernetes.io / role / elb                         = 1
    "kubernetes.io/cluster/${module.eks.cluster_name}" = 1
  }

  private_subnet_tags = {
    kubernetes.io / role / internal-elb                = 1
    "kubernetes.io/cluster/${module.eks.cluster_name}" = 1
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  map_public_ip_on_launch = true
}
