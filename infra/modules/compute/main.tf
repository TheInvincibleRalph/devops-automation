# IAM Role & Profile
resource "aws_iam_role" "permission" {
  name = "${var.prefix_tag}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = toset(var.iam_policy_arns)
  role       = aws_iam_role.permission.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.prefix_tag}-profile"
  role = aws_iam_role.permission.name
}

resource "aws_security_group" "sg" {
  name        = "${var.prefix_tag}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.prefix_tag}"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Compute Instance
resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  user_data              = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = {
    Name = var.prefix_tag
  }
}