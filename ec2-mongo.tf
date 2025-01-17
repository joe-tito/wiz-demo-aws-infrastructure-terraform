resource "aws_security_group" "this" {

  name = "mongo-db-security-group"

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongo" {

  ami                         = "ami-0e1bed4f06a3b463d" # Ubuntu 22.04 LTS
  instance_type               = "t2.micro"
  key_name                    = var.key_pair_name
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

              echo "use admin" >> mongo-setup.js
              echo 'db.createUser({ user: "${var.mongo_user}", pwd: "${var.mongo_password}", roles: ["userAdminAnyDatabase"] })' >> mongo-setup.js
              mongosh < mongo-setup.js

              sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

              systemctl restart mongod

              EOF
  depends_on                  = [aws_security_group.this]
}
