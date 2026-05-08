variable "prefix_tag" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID to launch the instance in"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the Jenkins server"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.medium" 
}

variable "key_name" {
  description = "The SSH key pair name"
  type        = string
}

variable "iam_policy_arns" {
  type    = list(string)
  default = []
}

variable "user_data" {
  type    = string
  default = null
}

variable "root_volume_size" { default = 20 }
variable "root_volume_type" { default = "gp3" }

variable "ingress_rules" {
  type = list(object({
    port        = number
    cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}