resource "aws_instance" "this" {
  ami                    = "ami-09c813fb71547fc4f"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  instance_type          = "t3.micro"
  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  #Adding provisioner to avoid manull installation
  user_data = file("docker.sh")
  # provisioner "remote-exec" {
  #   inline = [
       
  #     "lsblk", #before docker disk space
  #     "sudo growpart /dev/nvme0n1 4",
  #     "sudo lvextend -l +50%FREE /dev/RootVG/rootVol",
  #     "sudo lvextend -l +50%FREE /dev/RootVG/varVol",
  #     "sudo xfs_growfs /",
  #     "sudo xfs_growfs /var",
  #     "df -hT", #to check the diskapce partition

  #     "sudo dnf -y install dnf-plugins-core",
  #     "sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo",
  #     "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
  #     "sudo systemctl enable --now docker",
  #     "sudo systemctl start docker",
  #     "sudo usermod -aG docker ec2-user"
  #   ]
  # }
  
  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   password    = "DevOps321"
  #   host        = self.public_ip
  # }
  # #Ending provisioner code

  tags = {
    Name    = "docker-demo"
    
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS all inbound trafficto  all outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_tls"
  }
}
output "docker_ip" {
  value       = aws_instance.this.public_ip
}
