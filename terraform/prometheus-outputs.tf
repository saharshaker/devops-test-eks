output "prometheus_ec2_public_ip" {
  value       = aws_eip.prometheus_eip.public_ip
  description = "your Prometheus EC2 instance public IP"
}
