output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.ec2.private_ip
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.permission.arn
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = aws_security_group.sg.id
}