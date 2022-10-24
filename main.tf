variable "hostnames" {
  default = ["server1.sh", "server2.sh",
  "server3.sh"]
}

data "template_file" "user-data" {
  count    = "${length(var.hostnames)}"
  template = "${file("${element(var.hostnames, count.index)}")}"
}


# Resource-1: Create EC2 Instance
resource "aws_instance" "VIJAY-TERRAFORM" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.my-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.public-SG.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.vijay_profile.name 

  user_data                   = "${element(data.template_file.user-data.*.rendered, count.index)}"

  tags = {
    "Name"  = "Terraform-${count.index + 1}"
  }

}


resource "aws_ssm_parameter" "private_ips" {
 name        = "/test/private-ip"
 description = "private ips"
 type        = "StringList"
 value       = join(",", aws_instance.VIJAY-TERRAFORM.*.private_ip)

 tags = {
   environment = "Testing-private"
 }
 depends_on = [
   aws_instance.VIJAY-TERRAFORM
 ]
}


resource "aws_ssm_parameter" "public_ips" {
 name        = "/test/public-ip"
 description = "public ips"
 type        = "StringList"
 value       = join(",", aws_instance.VIJAY-TERRAFORM.*.public_ip)

 tags = {
   environment = "Testing-public"
 }
 depends_on = [
   aws_instance.VIJAY-TERRAFORM
 ]
}


resource "null_resource" "local_provisioners1" {
  count = "${var.instance_count}"
  depends_on = [
   aws_ssm_parameter.private_ips
 ]
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.VIJAY-TERRAFORM.*.private_ip, count.index)} >> hosts.private"
  }
}


resource "null_resource" "local_provisioners2" {
  count = "${var.instance_count}"
  depends_on = [
   aws_ssm_parameter.public_ips
 ]
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.VIJAY-TERRAFORM.*.public_ip, count.index)} >> hosts.public"
  }
}
