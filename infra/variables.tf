variable "environment" {
   description = "Name of this environment"
   default = "production"
}

variable "aws_access_key" {
    description = "Access key for AWS"
}

variable "aws_secret_key" {
    description = "Secret key for AWS"
}

variable "ami" {
    description = "AMI to use for Consul"
}

variable "ami_user" {
    description = "Username to use when connecting to the consul server"
}

variable "key_name" {
    description = "SSH key name"
}


variable "subnet_ids" {
    description = "Subnet IDs"
}

variable "subnet_cidrs" {
   description = "Subnet CIDRs"
}

variable "subnet_availability_zones" {
  description = "Subnet availability zones"
}

variable "vpc_cidr" {
    description = "VPC CIDR"
}

variable "vpc_id" {
    description = "VPC ID"
}

variable "aws_region" {
    description = "Region where we will operate."
    default = "eu-west-1"
}

variable "aws_availability_zones" {
    description  = "Availability zones where we will operate."
    default =  "eu-west-1a,eu-west-1b,eu-west-1c,eu-west-1d"
}

variable "instance_type" {
    description = "Instance type for the consul servers"
    default = "t2.micro"
}

variable "servers_count" {
    description = "Number of servers to create - 1, 3, or 5"
    default = "3"
}


