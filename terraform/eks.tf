data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.2.1"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  subnets            = module.vpc.private_subnets
  manage_aws_auth    = true
  config_output_path = "${path.module}/artifacts/"

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
  "scheduler"]

  tags   = var.default_tags
  vpc_id = module.vpc.vpc_id
  map_roles = [
    {
      username = "system:node:{{EC2PrivateDNSName}}"
      groups    = ["system:bootstrappers", "system:nodes"]
      rolearn = module.eks.worker_iam_role_arn
    }
  ]
  map_users = var.map_users
}

data "aws_eks_cluster" "main" {
  name = module.eks.cluster_id
}


resource "aws_eks_node_group" "wg-b2b-prio" {
  cluster_name    = var.cluster_name
  node_group_name = "b2b-prio-1"
  tags = {
    Name = "${var.cluster_name}-wg-b2b-prio"
  }
  node_role_arn  = module.eks.worker_iam_role_arn
  instance_types = [var.eks_b2b_prio_instance_types]
  subnet_ids     = module.vpc.private_subnets
  version        = var.cluster_version
  scaling_config {
    min_size     = var.b2b_prio_min_size
    max_size     = var.b2b_prio_max_size
    desired_size = var.b2b_prio_desired_size
  }
  lifecycle {
    ignore_changes = [
    ]
  }
}

resource "aws_eks_node_group" "wg-sts-prio" {
  cluster_name    = var.cluster_name
  node_group_name = "sts-prio-1"
  tags = {
    Name = "${var.cluster_name}-wg-sts-prio"
  }
  node_role_arn  = module.eks.worker_iam_role_arn
  instance_types = [var.eks_sts_prio_instance_types]
  subnet_ids     = module.vpc.private_subnets
  version        = var.cluster_version
  scaling_config {
    min_size     = var.sts_prio_min_size
    max_size     = var.sts_prio_max_size
    desired_size = var.sts_prio_desired_size
  }
  lifecycle {
    ignore_changes = [
    ]
  }
}

resource "aws_iam_role_policy_attachment" "workers_acm_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly"
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_acm_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly"
  role       = module.eks.cluster_iam_role_name
}


resource "aws_iam_policy" "cloudwatch_metrics_policy" {
  name        = "${var.cluster_name}-cloudwatch_metrics_policy"
  path        = "/"
  description = "Policy for pushing cloudwatch metrics data"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "eks-test-cluster-node-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = module.eks.worker_iam_role_name
}


resource "aws_iam_role_policy_attachment" "eks-test-cluster-node-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = module.eks.worker_iam_role_name
}


resource "aws_iam_role_policy_attachment" "eks-test-cluster-node-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_role_policy_attachment" "eks-test-cluster-node-role-AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = module.eks.worker_iam_role_name
}


resource "aws_iam_role_policy_attachment" "workers_cloudwatch_metrics" {
  policy_arn = aws_iam_policy.cloudwatch_metrics_policy.arn
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_cloudwatch_metrics" {
  policy_arn = aws_iam_policy.cloudwatch_metrics_policy.arn
  role       = module.eks.cluster_iam_role_name
}
