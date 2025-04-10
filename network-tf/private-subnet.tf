resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.128.0/18"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-eks Subnet"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}