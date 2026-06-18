# VPC Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}

# EC2 Outputs
output "app_instance_id" {
  description = "The ID of the application EC2 instance."
  value       = module.app_ec2.instance_id
}

output "app_instance_public_ip" {
  description = "The public IP of the application EC2 instance."
  value       = var.allocate_eip_app ? aws_eip.app[0].public_ip : module.app_ec2.public_ip
}

output "app_instance_private_ip" {
  description = "The private IP of the application EC2 instance."
  value       = module.app_ec2.private_ip
}

output "db_instance_id" {
  description = "The ID of the database EC2 instance."
  value       = module.db_ec2.instance_id
}

output "db_instance_private_ip" {
  description = "The private IP of the database EC2 instance."
  value       = module.db_ec2.private_ip
}

output "app_live_url" {
  description = "Click this link to view the live eCommerce App"
  value       = "http://${var.allocate_eip_app ? aws_eip.app[0].public_ip : module.app_ec2.public_ip}"
}

output "jenkins_url" {
  description = "Click this link to access the Jenkins CI/CD server"
  value       = "http://${module.jenkins.public_ip}:8080"
}
