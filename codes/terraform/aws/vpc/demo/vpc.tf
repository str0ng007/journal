module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = var.create_database_subnet_group
  database_subnet_group_name   = var.database_subnet_group_name

  enable_nat_gateway = false
  single_nat_gateway = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "Role"                   = "subnet"
    "Profile"                = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "Role"                            = "subnet"
    "Profile"                         = "private"
  }

  database_subnet_tags = {
    "Role"    = "subnet"
    "Profile" = "database"
  }

  database_subnet_group_tags = {
    "Role"    = "SubnetGroup"
    "Profile" = "mysql"
  }

  tags = {
    Terraform   = "true"
    Environment = var.env
    Product     = "VPC"
  }
}
