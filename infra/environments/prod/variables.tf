# Provider Variable
variable "region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "aws_region" {
  description = "Region for AMI lookup and EC2 launch."
  type        = string
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
}

variable "availability_zone" {
  description = "The availability zone to use."
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC."
  type        = bool
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IPs on instance launch in the public subnet."
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}

# Security Group Variables
variable "app_sg_name" {
  description = "Name for the application security group."
  type        = string
}

variable "app_sg_description" {
  description = "Description for the application security group."
  type        = string
}

variable "app_sg_ingress_rules" {
  description = "List of ingress rules for the application security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
}

variable "app_sg_egress_rules" {
  description = "List of egress rules for the application security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
}

variable "db_sg_name" {
  description = "Name for the database security group."
  type        = string
}

variable "db_sg_description" {
  description = "Description for the database security group."
  type        = string
}

variable "db_sg_ingress_rules" {
  description = "List of ingress rules for the database security group."
  type = list(object({
    description        = string
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = list(string)
    ipv6_cidr_blocks   = list(string)
    security_group_ids = optional(list(string), [])
  }))
}

variable "db_sg_egress_rules" {
  description = "List of egress rules for the database security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
}

variable "jenkins_sg_name" {
  description = "Name for the Jenkins security group."
  type        = string
}

variable "jenkins_sg_description" {
  description = "Description for the Jenkins security group."
  type        = string
}

variable "jenkins_sg_ingress_rules" {
  description = "List of ingress rules for the Jenkins security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
}

variable "jenkins_sg_egress_rules" {
  description = "List of egress rules for the Jenkins security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
}

# EC2 Variables
variable "availability_zone_app" {
  description = "AZ to launch the app instance."
  type        = string
}

variable "instance_type_app" {
  description = "Instance type for the app EC2."
  type        = string
}

variable "associate_public_ip_address_app" {
  description = "Whether to assign public IP to app instance."
  type        = bool
}

variable "allocate_eip_app" {
  description = "Whether to allocate elastic ip address."
  type        = bool
}

variable "allocate_eip_db" {
  description = "Whether to allocate elastic ip address."
  type        = bool
}

variable "availability_zone_db" {
  description = "AZ to launch the DB instance."
  type        = string
}

variable "instance_type_db" {
  description = "Instance type for the DB EC2."
  type        = string
}

variable "associate_public_ip_address_db" {
  description = "Whether to assign public IP to DB instance."
  type        = bool
}

variable "key_name" {
  description = "Key pair name for EC2 access."
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM profile to attach to EC2 instances."
  type        = string
  default     = null
}

variable "app_ami_id" {
  description = "AMI for the app EC2 instance"
  type        = string
}

variable "db_ami_id" {
  description = "AMI for the DB EC2 instance"
  type        = string
}

# DB Configuration
variable "db_username" {
  description = "MySQL application database username."
  type        = string
  default     = "ecommerce_user"
}

variable "db_database" {
  description = "MySQL application database name."
  type        = string
  default     = "ecommerceapp"
}

variable "db_root_password" {
  description = "MySQL root password on the database server."
  type        = string
  sensitive   = true
}

variable "app_db_password" {
  description = "MySQL password for the application database user."
  type        = string
  sensitive   = true
}