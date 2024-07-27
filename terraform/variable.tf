variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS node group"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}
