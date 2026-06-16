# =============================================================
# STAGE 3: Docker Container (Privileged - Vulnerable)
# Zafiyet: --privileged flagı ve host disk bağlantısı ile çalışan servis
# =============================================================

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.lab_prefix}-ec2-profile"
  role = aws_iam_role.admin_role.name
}

resource "aws_security_group" "lab_sg" {
  name        = "${var.lab_prefix}-sg"
  description = "Cloud Security Lab Security Group"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "HTTP App"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Stage = "3-Container-Escape" }
}

resource "aws_instance" "vulnerable_ec2" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 us-east-1
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  # Başlangıç betiği: Runtime kurulumu ve CTF Flag yerleşimi
  user_data = base64encode(<<-EOT
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    usermod -aG docker ec2-user

    
    mkdir -p /root
    echo "FLAG{cl0ud_esc4p3_succ3ss}" > /root/flag.txt

    
    docker run -d \
      --privileged \
      --name cloudsec-vulnerable-app \
      -v /:/host \
      -p 8080:80 \
      nginx:alpine

    echo "Lab container started" >> /var/log/lab-setup.log
  EOT
  )

  tags = {
    Name  = "${var.lab_prefix}-vulnerable-ec2"
    Stage = "3-Container-Escape"
  }
}
