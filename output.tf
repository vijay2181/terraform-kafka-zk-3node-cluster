
output "public_ip_addr" {
  value = aws_instance.VIJAY-TERRAFORM.*.public_ip
  description = "The public IP address of the main server instance"
}

output "private_ip_addr" {
  value = aws_instance.VIJAY-TERRAFORM.*.private_ip
  description = "The public IP address of the main server instance"
}



output "private_ip_addr1" {
  value = "${aws_instance.VIJAY-TERRAFORM.0.private_ip}"
}

output "private_ip_addr2" {
  value = "${aws_instance.VIJAY-TERRAFORM.1.private_ip}"
}




data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

output "profile" {
  value = var.profile
}