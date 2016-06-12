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

variable "aws_region" {
    description = "Region where we will operate."
    default = "eu-west-1"
}

variable "aws_availability_zones" {
    description  = "Availability zones where we will operate."
    default =  "eu-west-1a,eu-west-1b,eu-west-1c,eu-west-1d"
}

variable "consul_servers" {
    description = "Addresses of the consul servers"
}

variable "ami" {
    description = "AMI to use for the nomad workers"
}

variable "consul_security_group" {
    description = "Security group for consul"
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


variable "instance_type" {
    description = "Instance type for the nomad workers"
    default = "c4.large"
}

variable "servers_count" {
    description = "Number of workers to create"
    default = "1"
}


variable "route53_zone_id" {
    description = "Zone id for route53 hosted zone"
}

variable "route53_domain_name" {
    description = "Route53 hosted zone apex"
}
