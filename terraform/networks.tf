data "aws_availability_zones" "available" {
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name = "eks-${var.cluster_name}"
  cidr = var.network_cidr

  azs = data.aws_availability_zones.available.names

  private_subnets = var.network_private_subnets
  public_subnets = var.network_public_subnets
  enable_nat_gateway = true
  single_nat_gateway = !var.one_nat_gateway_per_az
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_dns_hostnames = true

  tags = var.default_tags

  # NOTE: Without vpc_tags specified, terraform tried to delete the tag.
  vpc_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = merge(var.default_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  })

  private_subnet_tags = merge(var.default_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_security_group" "eks_internal" {
  name_prefix = "wg_access"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol = -1
    self = true
    from_port = 0
    to_port = 0
  }

  ingress {
    protocol = -1
    from_port = 0
    to_port = 0
    security_groups = [
      module.eks.worker_security_group_id,
      module.eks.cluster_security_group_id,
      data.aws_eks_cluster.main.vpc_config.0.cluster_security_group_id
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = var.default_tags
}
