module "mysql_db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mysql-${var.env}-sg"
  description = "Replica MySQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.env
    Product     = "VPC"
    Role        = "SecurityGroup"
    Profile     = "mysql"
  }

}

module "documentdb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "documentdb-${var.env}-sg"
  description = "DocumentDB SecurityGroup"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      description = "DocumentDB access"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.env
    Product     = "VPC"
    Role        = "SecurityGroup"
    Profile     = "documentdb"
  }

}

