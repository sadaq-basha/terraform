resource "aws_docdb_subnet_group" "eks-docdb" {
  name = "eks-dbs-${var.cluster_name}-docdb"

  subnet_ids = module.vpc.private_subnets

  tags = var.default_tags
}

resource "random_string" "mongo_password" {
  length = 16
  special = false
}


resource "aws_docdb_cluster" "mongo" {
  cluster_identifier = "docdb-eks-${var.cluster_name}"
  availability_zones = data.aws_availability_zones.available.names
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  skip_final_snapshot = true

  db_subnet_group_name = aws_docdb_subnet_group.eks-docdb.name

  vpc_security_group_ids = [
    aws_security_group.eks_internal.id
  ]

  master_username = "serverapp"
  master_password = random_string.mongo_password.result

  tags = var.default_tags
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count = 1 # TODO: Check whether the parameter is appropriate before going to production
  cluster_identifier = aws_docdb_cluster.mongo.id
  identifier = "eks-${var.cluster_name}-docdb-${count.index}"
  instance_class = "db.${var.docdb_instance_size}"

  tags = var.default_tags
}
