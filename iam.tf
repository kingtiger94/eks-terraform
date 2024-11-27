resource "aws_iam_role" "eks_cluster" {
  name = "${local.cluster_name}-eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_nodes" {
  name = "${local.cluster_name}-nodes-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}
resource "aws_iam_role_policy_attachment" "eks_nodes_administrator_access" {  
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  
  role       = aws_iam_role.eks_nodes.name  
}
resource "aws_iam_policy" "ebs_csi_policy" {  
  name   = "EBSCSIPolicy"  
  description = "IAM policy for EBS CSI Driver"  
  policy = jsonencode({  
    "Version" = "2012-10-17"  
    "Statement" = [  
      {  
        "Effect" = "Allow"  
        "Action" = [  
          "ec2:CreateVolume",  
          "ec2:AttachVolume",  
          "ec2:DeleteVolume",  
          "ec2:DescribeVolumes",  
          "ec2:DetachVolume",  
          "ec2:CreateSnapshot",  
          "ec2:DeleteSnapshot",  
          "ec2:DescribeSnapshots"  
        ]  
        "Resource" = "*"  
      }  
    ]  
  })  
}  

resource "aws_iam_role_policy_attachment" "attach_ebs_csi_policy" {  
  policy_arn = aws_iam_policy.ebs_csi_policy.arn  
  role       = aws_iam_role.eks_nodes.name
}
