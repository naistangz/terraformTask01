# AWS Region Code
variable "region" {
  default = "eu-west-1"
}

# AWS Secret Key Name
variable "key_name" {
//  default = "aws_tang"
}

//variable "public_key" {
//  default = "aws_tang.pem"
//}

# Availability Zone Names
variable "availabilityZone1a" {
  default = "eu-west-1a"
}

variable "availabilityZone1b" {
  default = "eu-west-1b"
}

variable "availabilityZone1c" {
  default = "eu-west-1c"
}

variable "availabilityZones_EU" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

# AMIs
# Ubuntu Server 18.04
variable "amiapp" {
  default = "ami-0823c236601fef765"
}

# Instance Type
variable "instance_type" {
  default = "t2.micro"
}

# How many instances do we want to launch?
variable "instance_count" {
  default = "2"
}

//variable "instance_ids" {
//  type = "list"
//  instance_ids = "${list("${aws_instance.web_app1.id}", "${aws_instance.web_app2.id}")}"
//}


# DNS HostNames and Support
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

# CIDR NOT RECOMMENDED
variable "destination_cidr_block" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  default = ["10.0.0.0/16", "10.1.0.0/16"]
//  type = string
}

# Private CIDR Blocks for Subnets
variable "private_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.3.0/24"]
}

# Public CIDR Blocks for Subnets
variable "public_subnet_cidr_blocks" {
  default = ["10.0.4.0/24","10.0.2.0/24"]
}