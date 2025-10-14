resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus-sg"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

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

resource "aws_instance" "prometheus" {
  ami             = var.prometheus_ec2_ami_id
  instance_type   = var.prometheus_ec2_instance_type
  subnet_id       = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]
  key_name        = var.prometheus_ec2_key_name
  associate_public_ip_address = true
  user_data = templatefile("files/prometheus-installation.sh.tftpl", {
    nlb_ip_1 = aws_eip.nlb_eip_1.public_ip,
    nlb_ip_2 = aws_eip.nlb_eip_2.public_ip
  })
  tags = {
    Name = var.name
  }
}

resource "aws_eip" "prometheus_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-prometheus-eip"
  }
}

resource "aws_eip_association" "prometheus_assoc" {
  instance_id   = aws_instance.prometheus.id
  allocation_id = aws_eip.prometheus_eip.allocation_id
}