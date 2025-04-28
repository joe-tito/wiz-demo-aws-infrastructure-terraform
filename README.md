# Infrastructure for Web App Running on AWS EKS

This repository sets up the required infrastructure to deploy a containerized NextJS web application to AWS EKS which interacts with MongoDB running on an EC2 instance.

This repo deploys the following:

- VPC / Public & Private Subnets
- Load Balancer & NAT Gateway
- ECR to store images
- EKS to run NextJS containerized web application
- MongoDB running on an EC2 node
- S3 for storing DB backups

![Architecture](/images/architecture.png)

# Terraform Docs

## Requirements

| Name                                                   | Version |
| ------------------------------------------------------ | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.84 |

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                      | 5.84.0  |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | 2.35.1  |

## Modules

| Name                                                                    | Source                                 | Version |
| ----------------------------------------------------------------------- | -------------------------------------- | ------- |
| <a name="module_ec2_instance"></a> [ec2_instance](#module_ec2_instance) | terraform-aws-modules/ec2-instance/aws | n/a     |
| <a name="module_eks"></a> [eks](#module_eks)                            | terraform-aws-modules/eks/aws          | n/a     |
| <a name="module_vpc"></a> [vpc](#module_vpc)                            | terraform-aws-modules/vpc/aws          | n/a     |

## Resources

| Name                                                                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)                                                         | resource    |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy)                                           | resource    |
| [aws_iam_instance_profile.admin_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)                                    | resource    |
| [aws_iam_role.admin_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                               | resource    |
| [aws_iam_role_policy.admin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                               | resource    |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                   | resource    |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                     | resource    |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                           | resource    |
| [aws_security_group.egress_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                              | resource    |
| [aws_security_group.ingress_mongo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                                | resource    |
| [kubernetes_cluster_role_binding.web_app_cluster_admin_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource    |
| [kubernetes_deployment.web-app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                                | resource    |
| [kubernetes_service.ec2-mongo-service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                            | resource    |
| [kubernetes_service.web-app-service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                              | resource    |
| [kubernetes_service_account.web_app_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account)                      | resource    |
| [aws_iam_policy_document.ecr_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                             | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                            | data source |

## Inputs

| Name                                                                        | Description                                  | Type     | Default      | Required |
| --------------------------------------------------------------------------- | -------------------------------------------- | -------- | ------------ | :------: |
| <a name="input_container_name"></a> [container_name](#input_container_name) | Name used for the web app container          | `string` | `"web-app"`  |    no    |
| <a name="input_container_port"></a> [container_port](#input_container_port) | Port to expose for the web app container     | `number` | `3000`       |    no    |
| <a name="input_container_tag"></a> [container_tag](#input_container_tag)    | Tag version of container image to use        | `string` | `"386e4bab"` |    no    |
| <a name="input_key_pair_name"></a> [key_pair_name](#input_key_pair_name)    | Key pair used to ssh into mongo ec2 instance | `string` | n/a          |   yes    |
| <a name="input_mongo_password"></a> [mongo_password](#input_mongo_password) | Password user to create mongo database       | `string` | n/a          |   yes    |
| <a name="input_mongo_user"></a> [mongo_user](#input_mongo_user)             | Username used to create mongo database       | `string` | n/a          |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
