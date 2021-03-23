resource "aws_ecr_repository" "server-web" {
  count = var.cluster_name == "dev" ? 1 : 0
  name  = "ls-server/web"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "worker-app" {
  count = var.cluster_name == "dev" ? 1 : 0
  name  = "ls-server/workers"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "dashboard-server" {
  count = var.cluster_name == "dev" ? 1 : 0
  name  = "ls-server/dashboard-server"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "dashboard-web" {
  count = var.cluster_name == "dev" ? 1 : 0
  name  = "ls-server/dashboard-web"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "aws-ci" {
  count = var.cluster_name == "dev" ? 1 : 0
  name  = "ls-server/ci/aws"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role_policy_attachment" "workers_ecr_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = module.eks.worker_iam_role_name
}