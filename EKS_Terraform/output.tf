output "cluster_id" {
  value = aws_eks_cluster.ashu.id
}

output "node_group_id" {
  value = aws_eks_node_group.ashu.id
}

output "vpc_id" {
  value = aws_vpc.ashu_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.ashu_subnet[*].id
}
