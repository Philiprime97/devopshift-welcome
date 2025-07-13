provider "aws" {
  region = "us-east-2"
}

locals {
  vpc_id     = "vpc-0a691b1cda1dea4be"
  subnet_ids = ["subnet-09a9b4fe4e74051b3", "subnet-0fa3e3e7dad301962"]
}

resource "aws_security_group" "lb_sg97" {
  name        = "lb_security_group97"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = local.vpc_id
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0d1b5a8c13042c939"
  instance_type          = "t3.small"
  subnet_id              = local.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.lb_sg97.id]

  tags = {
    Name = "WebServer"
  }
}

resource "aws_lb" "application_lb97" {
  name               = "abc"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg97.id]
  subnets            = local.subnet_ids
}

resource "aws_lb_target_group" "web_target_group97" {
  name     = "web-target-group97"
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
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "web_instance_attachment97" {
  target_group_arn = aws_lb_target_group.web_target_group97.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

resource "aws_lb_listener" "http_listener97" {
  load_balancer_arn = aws_lb.application_lb97.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group97.arn
  }
}

output "web_server_id" {
  value = aws_instance.web_server.id
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "alb_dns_name" {
  value = aws_lb.application_lb97.dns_name
}