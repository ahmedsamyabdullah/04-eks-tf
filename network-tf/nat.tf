resource "aws_eip" "nat" {
  depends_on = [ aws_internet_gateway.main ]
  domain = "vpc" 
  
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "EKS Nat"
  }
}