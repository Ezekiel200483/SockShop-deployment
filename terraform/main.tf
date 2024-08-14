provider "aws" {
  region = var.region
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "socksShop-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "socks-shop-vpc"

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

# Security Group for EKS Control Plane
resource "aws_security_group" "eks_control_plane" {
  name        = "${local.cluster_name}-control-plane-sg"
  description = "Security group for EKS control plane"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTPS traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_worker_nodes" {
  name        = "${local.cluster_name}-worker-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow traffic from control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_control_plane.id]
  }

  ingress {
    description = "Allow all traffic within the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  cluster_security_group_id = aws_security_group.eks_control_plane.id

  eks_managed_node_group_defaults = {
    ami_type                    = "AL2_x86_64"
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_worker_nodes.id]
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = [var.node_instance_type]

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
    }

    two = {
      name = "node-group-2"

      instance_types = [var.node_instance_type]

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.min_size
    }
  }
}
