module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)  # Use all subnets
  cluster_endpoint_public_access = true
  iam_role_arn = aws_iam_role.eks_cluster.arn

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64_GPU"
  }

  eks_managed_node_groups = {
    one = {
      name          = "node-group-1"
      instance_types = ["g4dn.xlarge"]
      min_size      = 2
      max_size      = 2
      desired_size  = 2
      iam_role_arn  = aws_iam_role.eks_nodes.arn
      key_name      = aws_key_pair.eks_key.key_name
      subnet_ids    = module.vpc.public_subnets  # Node group in public subnets
    }
  }
}

resource "aws_security_group_rule" "eks_node_inbound_all" {
  description       = "Allow all inbound traffic to EKS nodes"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.node_security_group_id
}

# Add-ons for EKS
resource "aws_eks_addon" "coredns" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "coredns"
  addon_version = "v1.11.3-eksbuild.1"
  depends_on    = [module.eks]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "vpc-cni"
  addon_version = "v1.18.3-eksbuild.2"
  depends_on    = [module.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "kube-proxy"
  addon_version = "v1.31.0-eksbuild.2"
  depends_on    = [module.eks]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.2-eksbuild.2"
  depends_on    = [module.eks]
}
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.37.0-eksbuild.1"
  depends_on    = [module.eks]
}
