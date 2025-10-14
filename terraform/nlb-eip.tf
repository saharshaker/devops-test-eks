resource "aws_eip" "nlb_eip_1" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-nlb-eip-1"
  }
}

resource "aws_eip" "nlb_eip_2" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-nlb-eip-2"
  }
}
