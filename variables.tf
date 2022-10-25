# General Variables

#region
variable "ami_id" {
  description = "Default ami id for ubuntu"
  type        = string
  default     = "ami-017fecd1353bcc96e"
}

#region
variable "region" {
  description = "Default region for provider"
  type        = string
  default     = "us-west-2"
}

#instance_type
variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.medium"
}

#key_pair name
variable "key_name" {
  description = "ec2 keypair name"
  type        = string
  default     = "ninaquad" #give keypair name in aws 
}


#username
variable "username" {
  description = "aws username"
  type        = string
  default     = "ubuntu" #give user-name
}

#profile
variable "profile" {
  description = "aws profile name"
  type        = string
  default     = "test" #give profile name
}


#instance count
variable "instance_count" {
  default = "3"
}


variable "hostnames" {
  default = ["configs/server1.sh", "configs/server2.sh",
  "configs/server3.sh"]
}