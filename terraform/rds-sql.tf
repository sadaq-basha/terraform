locals {
  system_type = "b2b"
}

resource "aws_db_subnet_group" "eks-mariadb" {
  name = "eks-dbs-${var.cluster_name}"

  subnet_ids = module.vpc.private_subnets

  tags = var.default_tags
}

resource "aws_db_parameter_group" "mariadb-default" {
  name = "${var.cluster_name}-rds-mariadb"
  family = "mariadb10.3"

  parameter {
    name = "max_connections"
    value = "2048"
  }

  parameter {
    name = "wait_timeout"
    value = "300"
  }
}

resource "random_string" "mariadb_password" {
  length = 16
  special = false
}

resource "aws_db_instance" "mariadb" {
  identifier            = "${lookup(var.default_tags, "environment", "")}-${local.system_type}-database"
  allocated_storage = 100 # TODO: Check whether the parameter is appropriate before going to production
  max_allocated_storage = 150 # TODO: Check whether the parameter is appropriate before going to production
  enabled_cloudwatch_logs_exports  = ["audit", "error", "general", "slowquery"]
  storage_type = "gp2"
  engine = "mariadb"
  engine_version = "10.3"
  instance_class = "db.${var.rds_instance_size}"
  apply_immediately = true

  skip_final_snapshot = true

  backup_retention_period = "30"
  parameter_group_name = aws_db_parameter_group.mariadb-default.name

  backup_window = "02:00-03:00"
  maintenance_window = "Sat:04:00-Sat:06:00"

  name = var.cluster_name
  username = "user"
  password = random_string.mariadb_password.result

  tags = var.default_tags

  multi_az = var.rds_multi_az
  monitoring_interval = var.rds_monitoring_interval

  vpc_security_group_ids = [
    aws_security_group.eks_internal.id]
  db_subnet_group_name = aws_db_subnet_group.eks-mariadb.name

  lifecycle {
    ignore_changes = [
      identifier,
    ]
  }
}
