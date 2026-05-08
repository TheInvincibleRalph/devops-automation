variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "The VPC ID to associate with the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group."
  type = list(object({
    description        = string
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string), [])
    ipv6_cidr_blocks   = optional(list(string), [])
    security_group_ids = optional(list(string), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}