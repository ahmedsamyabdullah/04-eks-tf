resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default" # shared vm low cost
  enable_dns_support = true
  enable_dns_hostnames = true 
  tags = {
    Name = "EKS-VPC"
  }
}