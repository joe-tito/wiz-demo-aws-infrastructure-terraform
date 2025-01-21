module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "wiz-demo-cluster"
  cluster_version = "1.31"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

}

resource "kubernetes_service" "web-app-service" {

  metadata {
    name = "${var.container_name}-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = var.container_name
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 3000
    }


    type                = "LoadBalancer"
    load_balancer_class = "eks.amazonaws.com/nlb"
  }

  wait_for_load_balancer = true
}

resource "kubernetes_service" "ec2-mongo-service" {

  metadata {
    name = "ec2-mongo-service"
  }

  spec {
    external_name = module.ec2_instance.private_dns
    selector = {
      "app.kubernetes.io/name" = var.container_name
    }
    type = "ExternalName"
  }
}

resource "kubernetes_deployment" "web-app" {

  metadata {
    name = var.container_name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.container_name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = var.container_name
        }
      }

      spec {
        container {
          name  = var.container_name
          image = "${aws_ecr_repository.this.repository_url}:f1899b11"

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}
