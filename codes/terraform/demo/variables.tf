/*
variable "root_block_device_size" {
  type = number
}
*/

variable "root_block_device" {
  type    = list(any)
  default = []
}

variable "ami" {
  description = "AWS AMI's"
  type        = string
}

variable "instance_type" {
  description = "AWS Instance Type"
  type        = string

}

variable "public_key" {
  description = "Public Key"
  type        = string
}

variable "instance_count" {
  description = "Instance Count"
  type        = string
}
