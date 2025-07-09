provider "aws" {
  region = var.region
}

provider "time" {
}




variable "region" {
  default = "us-west-1"
}

variable "YOURNAME" {
    default = "philip"
  
}

resource "time_sleep" "wait_for_ip" {
  create_duration = "20s"  # Wait for 10 seconds
}


resource "aws_security_group" "sg" {
  
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
}

resource "aws_instance" "vm" {
  ami           = "ami-0716139194fc514be" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id = "subnet-06acd0b316280afeb"

  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "${var.YOURNAME}-vm"
  }
}

resource "null_resource" "check_public_ip" {
  provisioner "local-exec" {
    command = <<EOT
      if [ -z "${aws_instance.vm.public_ip}" ]; then
        echo "ERROR: Public IP address was not assigned." >&2
        exit 1
      fi
    EOT
  }

  depends_on = [aws_instance.vm]
}


output "vm_public_ip" {
  value       = aws_instance.vm.public_ip
  description = "Public IP address of the VM"
  depends_on = [ null_resource.check_public_ip ]
}