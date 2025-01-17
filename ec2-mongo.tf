# resource "aws_key_pair" "this" {
#   key_name   = "joe-laptop"
#   public_key = var.public_key
# }

resource "aws_security_group" "this" {
  name = "mongo-db-security-group"
  # vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongo" {
  ami           = "ami-0e1bed4f06a3b463d" # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.this.key_name
  # subnet_id                   = aws_subnet.my_subnet_1.id
  security_groups             = [aws_security_group.this.name]
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install gnupg curl
              curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
              gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
              --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
              apt-get update
              apt-get install -y mongodb-org
              systemctl start mongod
              systemctl enable mongodb
              EOF
  depends_on                  = [aws_security_group.this]
}
