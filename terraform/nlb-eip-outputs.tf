output "nlb_eip_1_allocation_id" {
  description = "Allocation ID of the first NLB EIP"
  value       = aws_eip.nlb_eip_1.id
}

output "nlb_eip_2_allocation_id" {
  description = "Allocation ID of the second NLB EIP"
  value       = aws_eip.nlb_eip_2.id
}

output "nlb_eip_1_public_ip" {
  description = "Public IP address of the first NLB EIP"
  value       = aws_eip.nlb_eip_1.public_ip
}

output "nlb_eip_2_public_ip" {
  description = "Public IP address of the second NLB EIP"
  value       = aws_eip.nlb_eip_2.public_ip
}
