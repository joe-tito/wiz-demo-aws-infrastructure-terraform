module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wiz-demo"
  cidr = "10.0.0.0/16"

  azs             = ["es-east-1a", "es-east-1b", "es-east-1c"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  #   enable_nat_gateway = true
  #   enable_vpn_gateway = true
}
