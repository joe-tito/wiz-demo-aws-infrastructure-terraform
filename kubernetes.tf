########################
### Container registry
########################

resource "aws_ecr_repository" "this" {
  name                 = "wiz-demo-web-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

########################
# ECS cluster
########################

resource "aws_ecs_cluster" "this" {
  name = "wiz-demo-cluster"
}

########################
# IAM Permissions
########################

# creating an iam policy document for ecsTaskExecutionRole
data "aws_iam_policy_document" "kubernetes_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# creating an iam role with needed permissions to execute tasks
resource "aws_iam_role" "this" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.kubernetes_policy_document.json
}

# attaching AmazonECSTaskExecutionRolePolicy to ecsTaskExecutionRole
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################
# ECS Task Definition
########################

resource "aws_ecs_task_definition" "this" {
  family                   = "web-app-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "aws-crud-container",
      "image": "${aws_ecr_repository.this.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]           # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"              # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512                   # Specifying the memory our task requires
  cpu                      = 256                   # Specifying the CPU our task requires
  execution_role_arn       = aws_iam_role.this.arn # Stating Amazon Resource Name (ARN) of the execution role
}


########################
# Load balancer
########################

# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}

resource "aws_alb" "this" {
  name               = "web-app-lb" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.web_app_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "web_app_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
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

# Creating a target group for the load balancer
resource "aws_lb_target_group" "this" {
  name        = "web-app-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

# Creating a listener for the load balancer
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn # Referencing our target group
  }
}

########################
# ECS service
########################

# Creating the service
resource "aws_ecs_service" "this" {
  name            = "web-app-service"
  cluster         = aws_ecs_cluster.this.id          # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.this.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn # Referencing our target group
    container_name   = "web-app-container"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true                                                        # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.web_app_service_security_group.id}"] # Setting the security group
  }
}

# Creating a security group for the service
resource "aws_security_group" "web_app_service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.web_app_security_group.id}"]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
