module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name          = "ec2-mongo"
  instance_type = "t2.micro"
  ami           = "ami-0e1bed4f06a3b463d" # Ubuntu 22.04 LTS
  key_name      = var.key_pair_name
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.ingress_mongo_all.id,
    aws_security_group.ingress_ssh_all.id,
    aws_security_group.egress_internet.id
  ]

  user_data = <<-EOF
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
        systemctl unmask mongodb
        systemctl enable mongodb
        sleep 30

        echo "use admin" >> /tmp/mongo-setup.js
        echo "db.createUser({ user: '${var.mongo_user}', pwd: '${var.mongo_password}', roles: ['root'] })" >> /tmp/mongo-setup.js
        echo "db.createCollection('reasons')" >> /tmp/mongo-setup.js
        echo "db.reasons.insertMany([{reason: 'He built this super cool three-tiered web app'}, {reason: 'Everything is built as code with Terraform. How cool is that?'}, {reason: 'These reasons are stored & queried from Mongo}. {reason: 'He would add yet another, Joe, to the team!'}, {reason: 'He was obsessed with Wizards as a kid! Coincidence?'}])" >> /tmp/mongo-setup.js
        mongosh < /tmp/mongo-setup.js
        rm /tmp/mongo-setup.js

        echo "security:" >> /etc/mongod.conf
        echo "    authorization: enabled" >> /etc/mongod.conf

        sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

        systemctl restart mongod

        EOF
}
