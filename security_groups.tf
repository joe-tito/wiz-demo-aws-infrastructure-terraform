resource "aws_security_group" "ingress_mongo" {

  name   = "ingress-mongo"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Mongo"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
}

# resource "aws_security_group" "ingress_ssh_all" {

#   name   = "ingress-ssh-all"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     description = "SSH"
#     from_port   = 0
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

resource "aws_security_group" "egress_internet" {

  name   = "egress-internet"
  vpc_id = module.vpc.vpc_id

  egress {
    description = "Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
