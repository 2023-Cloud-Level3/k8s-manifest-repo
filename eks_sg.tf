# Kubernetes Security Groups

resource "aws_security_group" "efs-sg" {
  name = "eks-${var.efs_tag_name}-securitygroup"
  tags = {Name = "eks-${var.efs_tag_name}-securitygroup"}
  vpc_id = aws_vpc.eks_vpc.id
  
}

# ALLOW ALL TRAFFICS BETWEEN EC2 INSTANCES IN DEFAULT VPC
resource "aws_security_group_rule" "nfs" {
  type              = "ingress"
  from_port         = var.efs_nfs_sg_port 
  to_port           = var.efs_nfs_sg_port
  protocol          = "tcp"
  cidr_blocks       = [var.eks_vpc_cidr_range]
  security_group_id = aws_security_group.efs-sg.id
}

