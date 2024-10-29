variable "aws_account_id" {
  description = "the AWS account ID"
  type        = string

}

variable "region" {
  description = "AWS region"
  type        = string

}

variable "vpc_cidr" {
  description = "EKS VPC CIDR Block"
  type        = string

}

variable "azs" {
  description = "AWS Availability zones"
  type        = list(string)

}

variable "env" {
  description = "Environment"
  type        = string

}

variable "private_subnets" {
  description = "Private Subnets"
  type        = list(any)
}

variable "public_subnets" {
  description = "Public Subnets"
  type        = list(any)
}

variable "database_subnets" {
  description = "Database Subnets"
  type        = list(any)
}

variable "create_database_subnet_group" {
  description = "Toggle for DB subnet group creation"
  type        = bool
}

variable "database_subnet_group_name" {
  description = "Name of Database Subnet Group"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}
