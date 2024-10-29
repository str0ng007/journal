aws_account_id = "AWS_ACCOUNT_NUM"
region         = "us-east-1"
azs            = ["us-east-1a", "us-east-1b"]
vpc_cidr       = "10.0.0.0/16"


env      = "dev"
vpc_name = "demo-dev"

#reserve "10.0.192.0/19 and "10.0.224.0/19"
private_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]
public_subnets   = ["10.0.0.0/19", "10.0.32.0/19"]
database_subnets = ["10.0.128.0/19", "10.0.160.0/19"]

create_database_subnet_group = false
database_subnet_group_name   = "mysql-db-subnet-group"
#
# wireguard_ip = "34.203.197.237/32"


