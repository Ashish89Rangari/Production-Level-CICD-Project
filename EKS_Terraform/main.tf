
# Provider block
provider "aws" {
  region = "ap-south-1"
}

#VPC

resource "aws_vpc" "ashu_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ashu-vpc"
  }
}

# Subnet
resource "aws_subnet" "ashu_subnet" {
  count = 2
  vpc_id                  = aws_vpc.ashu_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.ashu_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "ashu-subnet-${count.index}"
  }
}
# IGW
resource "aws_internet_gateway" "ashu_igw" {
  vpc_id = aws_vpc.ashu_vpc.id

  tags = {
    Name = "ashu-igw"
  }
}

# Route Table

resource "aws_route_table" "ashu_route_table" {
  vpc_id = aws_vpc.ashu_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ashu_igw.id
  }

  tags = {
    Name = "ashu-route-table"
  }
}

# Route table association 

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.ashu_subnet[count.index].id
  route_table_id = aws_route_table.ashu_route_table.id
}

# EKS cluster Security Group
resource "aws_security_group" "ashu_cluster_sg" {
  vpc_id = aws_vpc.ashu_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ashu-cluster-sg"
  }
}

# EKS cluster Node Security Group

resource "aws_security_group" "ashu_node_sg" {
  vpc_id = aws_vpc.ashu_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ashu-node-sg"
  }
}

# EKS cluster Name
resource "aws_eks_cluster" "ashu" {
  name     = "ashu-cluster"
  role_arn = aws_iam_role.ashu_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.ashu_subnet[*].id
    security_group_ids = [aws_security_group.ashu_cluster_sg.id]
  }
}
# EKS Node group max and min size

resource "aws_eks_node_group" "ashu" {
  cluster_name    = aws_eks_cluster.ashu.name
  node_group_name = "ashu-node-group"
  node_role_arn   = aws_iam_role.ashu_node_group_role.arn
  subnet_ids      = aws_subnet.ashu_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.large"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.ashu_node_sg.id]
  }
}

# EKS Cluster IAM ROLE

resource "aws_iam_role" "ashu_cluster_role" {
  name = "ashu-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ashu_cluster_role_policy" {
  role       = aws_iam_role.ashu_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "ashu_node_group_role" {
  name = "ashu-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ashu_node_group_role_policy" {
  role       = aws_iam_role.ashu_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ashu_node_group_cni_policy" {
  role       = aws_iam_role.ashu_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ashu_node_group_registry_policy" {
  role       = aws_iam_role.ashu_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
