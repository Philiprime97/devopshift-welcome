provider "aws" {
  region = "us-east-2"
}

locals {
  vpc_id     = "vpc-084687c42bc6b6be7"
  subnet_ids = ["subnet-0dba81b888eb03998", "subnet-0caaa6ff3c583ca10"]
}

# Security Group for EC2 and ALB
resource "aws_security_group" "lb_sg977" {
  name        = "lb_security_group977_philip"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server_philip" {
  ami                    = "ami-0d1b5a8c13042c939"
  instance_type          = "t3.small"
  subnet_id              = local.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.lb_sg977.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              echo "<h1>Hello from Philip's EC2</h1>" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = {
    Name = "Philip-WebServer"
  }
}

# Application Load Balancer
resource "aws_lb" "application_lb977" {
  name               = "lb-philip"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg977.id]
  subnets            = local.subnet_ids
}

# Target Group
resource "aws_lb_target_group" "web_target_group977" {
  name     = "web-target-group977-philip"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

# Attach EC2 to Target Group
resource "aws_lb_target_group_attachment" "web_instance_attachment977" {
  target_group_arn = aws_lb_target_group.web_target_group977.arn
  target_id        = aws_instance.web_server_philip.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "http_listener977" {
  load_balancer_arn = aws_lb.application_lb977.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group977.arn
  }
}

# Outputs
output "web_server_philip_id" {
  value = aws_instance.web_server_philip.id
}

output "web_server_philip_public_ip" {
  value = aws_instance.web_server_philip.public_ip
}

output "alb_dns_name" {
  value = aws_lb.application_lb977.dns_name
}