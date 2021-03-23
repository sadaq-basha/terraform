terraform {
  required_version = ">= 0.12.0"
    backend "s3" {
    bucket = "ls-terraform-state-fc69"
    key = "terraform.tfstate"
    region = "ap-northeast-1"
    profile = "ls"
  }
}

provider "aws" {
  version = ">= 2.11"
  region = var.region

  profile = var.profile_name
}

data "template_file" "out" {
  template = file("${path.module}/templates/kube-config.tpl.yml")
  vars = {
    b2b_app_namespace = "b2b-application"
    mysql_host = base64encode(aws_db_instance.mariadb.address)
    mysql_port = base64encode(aws_db_instance.mariadb.port)
    mysql_user = base64encode(aws_db_instance.mariadb.username)
    mysql_password = base64encode(aws_db_instance.mariadb.password)
    mysql_db = base64encode(aws_db_instance.mariadb.name)
    redis_host = base64encode(concat(aws_elasticache_cluster.redis.cache_nodes.*.address, list(""))[0]) # TODO: Check how this works if we have several cache_nodes
    redis_port = base64encode(concat(aws_elasticache_cluster.redis.cache_nodes.*.port, list(0))[0]) # TODO: Check how this works if we have several cache_nodes
    mongo_host = base64encode(aws_docdb_cluster.mongo.endpoint)
    mongo_port = base64encode(aws_docdb_cluster.mongo.port)
    mongo_user = base64encode(aws_docdb_cluster.mongo.master_username)
    mongo_password = base64encode(aws_docdb_cluster.mongo.master_password)
    mongo_ssl = base64encode(true)
  }
}

resource "local_file" "kube-resources" {
  content = data.template_file.out.rendered
  filename = "${path.module}/artifacts/external-resources-${var.cluster_name}-secret.yml"
}