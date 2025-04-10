resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.0/18"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-eks Subnet"
    "kubernetes.io/cluster/eks"   = "shared"
    "kubernetes.io/role/elb"      = "1"
  }
}