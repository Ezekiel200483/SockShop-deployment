variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"  # Change this to your desired region
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.23"
}

variable "node_instance_type" {
  description = "The instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "min_size" {
  description = "The minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "The desired number of worker nodes"
  type        = number
  default     = 2
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}