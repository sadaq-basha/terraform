resource "aws_elasticache_parameter_group" "redis-default" {
  name = "${var.cluster_name}-rds-redis"
  family = "redis3.2"
}

resource "aws_elasticache_subnet_group" "eks-redis" {
  name = "eks-dbs-${var.cluster_name}"

  subnet_ids = module.vpc.private_subnets

}

resource "aws_elasticache_cluster" "redis" {
  cluster_id = "eks-${var.cluster_name}-cache"
  engine = "redis"
  node_type = "cache.${var.cache_instance_size}"
  num_cache_nodes = 1 # TODO: Check whether the parameter is appropriate before going to production
  parameter_group_name = aws_elasticache_parameter_group.redis-default.name
  engine_version = "3.2.10"
  port = 6379

  security_group_ids = [
    aws_security_group.eks_internal.id]

  subnet_group_name = aws_elasticache_subnet_group.eks-redis.name

  tags = var.default_tags
}
