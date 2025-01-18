locals {
  container_name = "wiz-demo-web-app"
  container_port = 3000
}

# ########################
# ### Container registry
# ########################

resource "aws_ecr_repository" "this" {
  name                 = "wiz-demo-web-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# # ########################
# # # ECS cluster
# # ########################

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "wiz-demo-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {

    wiz-demo-web-app = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        # fluent-bit = {
        #   cpu       = 512
        #   memory    = 1024
        #   essential = true
        #   image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
        #   firelens_configuration = {
        #     type = "fluentbit"
        #   }
        #   memory_reservation = 50
        # }

        (local.container_name) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = aws_ecr_repository.this.repository_url
          //image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          port_mappings = [
            {
              name          = local.container_name
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            }
          ]

          readonly_root_filesystem = false

          #   dependencies = [{
          #     containerName = "fluent-bit"
          #     condition     = "START"
          #   }]

          #   enable_cloudwatch_logging = false
          #   log_configuration = {
          #     logDriver = "awsfirelens"
          #     options = {
          #       Name                    = "firehose"
          #       region                  = "eu-west-1"
          #       delivery_stream         = "my-stream"
          #       log-driver-buffer-limit = "2097152"
          #     }
          #   }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = local.container_port
            dns_name = local.container_name
          }
          port_name      = local.container_name
          discovery_name = local.container_name
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ex_ecs"].arn
          container_name   = local.container_name
          container_port   = local.container_port
        }
      }

      subnet_ids = module.vpc.private_subnets

      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port
          to_port                  = local.container_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "wiz-demo-load-balancer"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }
}

resource "aws_service_discovery_http_namespace" "this" {
  name = "ex_ecs"
}









# # resource "aws_ecs_cluster" "this" {
# #   name = "wiz-demo-cluster"
# # }

# # ########################
# # # IAM Permissions
# # ########################

# # data "aws_iam_policy_document" "kubernetes_policy_document" {
# #   statement {
# #     actions = ["sts:AssumeRole"]

# #     principals {
# #       type        = "Service"
# #       identifiers = ["ecs-tasks.amazonaws.com"]
# #     }
# #   }
# # }

# # resource "aws_iam_role" "this" {
# #   name               = "ecsTaskExecutionRole"
# #   assume_role_policy = data.aws_iam_policy_document.kubernetes_policy_document.json
# # }

# # resource "aws_iam_role_policy_attachment" "this" {
# #   role       = aws_iam_role.this.name
# #   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# # }

# # ########################
# # # ECS Task Definition
# # ########################

# # resource "aws_ecs_task_definition" "this" {
# #   family                   = "web-app-task"
# #   container_definitions    = <<DEFINITION
# #   [
# #     {
# #       "name": "web-app-container",
# #       "image": "${aws_ecr_repository.this.repository_url}",
# #       "essential": true,
# #       "portMappings": [
# #         {
# #           "containerPort": 3000,
# #           "hostPort": 3000
# #         }
# #       ],
# #       "memory": 512,
# #       "cpu": 256
# #     }
# #   ]
# #   DEFINITION
# #   requires_compatibilities = ["FARGATE"]           # Stating that we are using ECS Fargate
# #   network_mode             = "awsvpc"              # Using awsvpc as our network mode as this is required for Fargate
# #   memory                   = 512                   # Specifying the memory our task requires
# #   cpu                      = 256                   # Specifying the CPU our task requires
# #   execution_role_arn       = aws_iam_role.this.arn # Stating Amazon Resource Name (ARN) of the execution role
# # }


# # ########################
# # # Load balancer
# # ########################

# # # # Providing a reference to our default VPC
# # # resource "aws_default_vpc" "default_vpc" {
# # # }

# # # # Providing a reference to our default subnets
# # # resource "aws_default_subnet" "default_subnet_a" {
# # #   availability_zone = "us-east-1a"
# # # }

# # # resource "aws_default_subnet" "default_subnet_b" {
# # #   availability_zone = "us-east-1b"
# # # }

# # # resource "aws_default_subnet" "default_subnet_c" {
# # #   availability_zone = "us-east-1c"
# # # }

# # resource "aws_alb" "this" {
# #   name               = "web-app-lb" # Naming our load balancer
# #   load_balancer_type = "application"
# #   subnets = [ # Referencing the default subnets
# #     "${aws_default_subnet.default_subnet_a.id}",
# #     "${aws_default_subnet.default_subnet_b.id}",
# #     "${aws_default_subnet.default_subnet_c.id}"
# #   ]
# #   # Referencing the security group
# #   security_groups = ["${aws_security_group.web_app_security_group.id}"]
# # }

# # # Creating a security group for the load balancer:
# # resource "aws_security_group" "web_app_security_group" {
# #   ingress {
# #     from_port   = 80
# #     to_port     = 80
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }
# # }

# # # Creating a target group for the load balancer
# # resource "aws_lb_target_group" "this" {
# #   name        = "web-app-target-group"
# #   port        = 80
# #   protocol    = "HTTP"
# #   target_type = "ip"
# #   vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
# #   health_check {
# #     matcher = "200,301,302"
# #     path    = "/"
# #   }
# # }

# # # Creating a listener for the load balancer
# # resource "aws_lb_listener" "this" {
# #   load_balancer_arn = aws_alb.this.arn # Referencing our load balancer
# #   port              = "80"
# #   protocol          = "HTTP"
# #   default_action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.this.arn # Referencing our target group
# #   }
# # }

# # ########################
# # # ECS service
# # ########################

# # # Creating the service
# # resource "aws_ecs_service" "this" {
# #   name            = "web-app-service"
# #   cluster         = aws_ecs_cluster.this.id          # Referencing our created Cluster
# #   task_definition = aws_ecs_task_definition.this.arn # Referencing the task our service will spin up
# #   launch_type     = "FARGATE"
# #   desired_count   = 3 # Setting the number of containers we want deployed to 3

# #   load_balancer {
# #     target_group_arn = aws_lb_target_group.this.arn # Referencing our target group
# #     container_name   = "web-app-container"
# #     container_port   = 3000 # Specifying the container port
# #   }

# #   network_configuration {
# #     subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
# #     assign_public_ip = true                                                        # Providing our containers with public IPs
# #     security_groups  = ["${aws_security_group.web_app_service_security_group.id}"] # Setting the security group
# #   }
# # }

# # # Creating a security group for the service
# # resource "aws_security_group" "web_app_service_security_group" {
# #   ingress {
# #     from_port = 0
# #     to_port   = 0
# #     protocol  = "-1"
# #     # Only allowing traffic in from the load balancer security group
# #     security_groups = ["${aws_security_group.web_app_security_group.id}"]
# #   }

# #   egress {
# #     from_port   = 0             # Allowing any incoming port
# #     to_port     = 0             # Allowing any outgoing port
# #     protocol    = "-1"          # Allowing any outgoing protocol 
# #     cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
# #   }
# # }

# # output "lb_dns" {
# #   value       = aws_alb.this.dns_name
# #   description = "AWS load balancer DNS Name"
# # }
