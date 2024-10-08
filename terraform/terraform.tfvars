region          = "us-east-1"
cluster_name    = "socksShop-eks"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
cluster_version = "1.27"
node_instance_type = "t3.large"
min_size        = 2
max_size        = 4
desired_size    = 3
