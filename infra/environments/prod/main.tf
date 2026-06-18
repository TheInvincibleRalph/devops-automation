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

module "app_sg" {
  source        = "../../modules/security"
  name          = var.app_sg_name
  description   = var.app_sg_description
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.app_sg_ingress_rules
  egress_rules  = var.app_sg_egress_rules
  tags          = var.tags
}

module "db_sg" {
  source      = "../../modules/security"
  name        = var.db_sg_name
  description = var.db_sg_description
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    for rule in var.db_sg_ingress_rules : merge(rule, {
      security_group_ids = length(try(rule.security_group_ids, [])) > 0 ? rule.security_group_ids : [module.app_sg.security_group_id]
    })
  ]
  egress_rules = var.db_sg_egress_rules
  tags         = var.tags
}

module "jenkins_sg" {
  source        = "../../modules/security"
  name          = var.jenkins_sg_name
  description   = var.jenkins_sg_description
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.jenkins_sg_ingress_rules
  egress_rules  = var.jenkins_sg_egress_rules
  tags          = var.tags
}

# CI/CD (The Jenkins Server)
module "jenkins" {
  source     = "../../modules/compute"
  prefix_tag = "jenkins-prod"
  subnet_id  = module.vpc.public_subnet_id
  ami_id     = var.app_ami_id
  key_name   = var.key_name

  security_group_ids = [module.jenkins_sg.security_group_id]

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]

  user_data = file("../../modules/compute/install_jenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}

# Application Layer (App)
module "app_ec2" {
  source        = "../../modules/compute"
  prefix_tag    = "web-app"
  subnet_id     = module.vpc.public_subnet_id
  ami_id        = var.app_ami_id
  instance_type = var.instance_type_app
  key_name      = var.key_name

  security_group_ids = [module.app_sg.security_group_id]

  user_data = templatefile("${path.module}/../../modules/compute/app_init.sh", {
    db_endpoint     = module.db_ec2.private_ip
    db_database     = var.db_database
    db_username     = var.db_username
    app_db_password = var.app_db_password
  })

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  tags = {
    Name = "application"
  }

  depends_on = [module.db_ec2]
}

module "db_ec2" {
  source          = "../../modules/compute"
  prefix_tag      = "mysql-db"
  subnet_id       = module.vpc.private_subnet_id
  ami_id          = var.db_ami_id
  instance_type   = var.instance_type_db
  key_name        = var.key_name
  iam_policy_arns = []

  security_group_ids = [module.db_sg.security_group_id]

  user_data = templatefile("${path.module}/../../modules/compute/db_init.sh", {
    db_root_password = var.db_root_password
    app_db_password  = var.app_db_password
    db_username      = var.db_username
    app_mysql_host   = "${join(".", slice(split(".", cidrhost(var.public_subnet_cidr, 0)), 0, 3))}.%"
    sql_schema_b64   = filebase64("${path.module}/../../../app/docker/database/ecommerceapp.sql")
  })

  tags = {
    Name = "database"
  }
}

resource "aws_eip" "app" {
  count    = var.allocate_eip_app ? 1 : 0
  domain   = "vpc"
  instance = module.app_ec2.instance_id

  tags = var.tags

  depends_on = [module.vpc]
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
  force_delete = true
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