resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default" # shared vm low cost
  enable_dns_support = true
  enable_dns_hostnames = true 
  tags = {
    Name = "EKS-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "EKS IGW"
  }
}

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
  depends_on = [ aws_internet_gateway.main ]
  tags = {
    Name = "EKS Nat"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-eks Subnet"
    "kubernetes.io/cluster/samy_eks"   = "shared"
    "kubernetes.io/role/elb"      = "1"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-eks Subnet"
    "kubernetes.io/cluster/samy_eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "EKS Public-RT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = aws_vpc.main.cidr_block  
    gateway_id     = "local"  
  }


  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "EKS Private-RT"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private"{
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}
############################# Security Groups ############################

######## Security Group for eks ######
resource "aws_security_group" "eks_sg" {
    name = "eks_sg"
    description = "Cluster communication with worker nodes"
    vpc_id = aws_vpc.main.id  
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_ingress_cluster" {
  description       = "Allow workstation to communicate with the cluster API Server"
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.eks_sg.id
  type = "ingress"

}

###### Security Group for Worker node #########
resource "aws_security_group" "worker_sg" {
  name = "worker_sg"
  description = "Security group for all nodes in the cluster"
  vpc_id = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]

  }

  tags = {
    "kubernetes.io/cluster/samy_eks" = "owned"
  }
}

resource "aws_security_group_rule" "worker_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port = 1025
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.eks_sg.id   ### Note: source from master to worker
  type = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.eks_sg.id
  type = "ingress"

}
