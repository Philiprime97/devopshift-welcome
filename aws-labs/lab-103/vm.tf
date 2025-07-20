resource "aws_instance" "vm" {
 ami                         = var.ami
 instance_type               = var.vm_size
 vpc_security_group_ids      = [aws_security_group.sg.id]
 subnet_id                   = aws_subnet.main_subnet.id
 associate_public_ip_address = true


 tags = {
   Name = var.vm_name
 }

 user_data = <<-EOF
    #!/bin/bash
        useradd -m -s /bin/bash ${var.admin_username}
        echo "${var.admin_username}:${var.admin_password}" | chpasswd
        usermod -aG wheel ${var.admin_username}
        echo "${var.admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${var.admin_username}
        chmod 440 /etc/sudoers.d/${var.admin_username}
        sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo systemctl restart sshd
    EOF

    depends_on = [aws_internet_gateway.igw]
 }



output "vm_public_ip" {
 value = aws_instance.vm.public_ip
}