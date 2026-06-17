# Networking (VPC)
module "vpc" {
  region                  = var.region
  source                  = "../../modules/vpc"
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  private_subnet_cidr     = var.private_subnet_cidr
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch
  
  tags = {
    Name        = "vpc"
    Environment = "prod"
  }
}

# CI/CD (The Jenkins Server)
module "jenkins" {
  source     = "../../modules/compute"
  prefix_tag = "jenkins-prod"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnet_id
  ami_id = var.app_ami_id
  key_name   = var.key_name

  ingress_rules = [
    {
      port        = 8080
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser", 
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"                 
  ]

  user_data  = file("../../modules/compute/install_jenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}

# Application Layer (App & DB)
module "app_ec2" {
  source        = "../../modules/compute"
  prefix_tag    = "web-app"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_id
  ami_id = var.app_ami_id  
  instance_type = "t3.small"
  key_name      = var.key_name

  ingress_rules = [
    {
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", 
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"       
  ]

user_data = templatefile("../../modules/compute/app_init.sh", {
    db_endpoint = module.db_ec2.private_ip
    db_password = var.db_password 
  })

  tags = {
    Name = "application"
  }
}

module "db_ec2" {
  source        = "../../modules/compute"
  prefix_tag    = "postgres-db"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.private_subnet_id 
  ami_id = var.app_ami_id
  instance_type = "t3.small"
  key_name      = var.key_name
  iam_policy_arns = []

  tags = {
    Name = "database"
  }
}

# CloudWatch: Centralized Logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ec2/php-ecommerce-app"
  retention_in_days = 7 

  tags = {
    Environment = "production"
    Application = "ecommerce"
  }
}

# CloudWatch: High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "app_cpu_alarm" {
  alarm_name          = "app-server-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120    
  statistic           = "Average"
  threshold           = 80    
  alarm_description   = "Triggers if the App Server CPU runs too hot"
  
  dimensions = {
    InstanceId = module.app_ec2.instance_id
  }
}


# Elastic Container Registry (ECR)

resource "aws_ecr_repository" "app_repo" {
  name                 = "php-ecommerce-app" 
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete         = true
  tags = {
    Name        = "php-ecommerce-app"
    Environment = "prod"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/${var.key_name}.pem"
  
  file_permission = "0400"
}