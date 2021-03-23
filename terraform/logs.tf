resource "aws_cloudwatch_log_group" "kube" {
  name = "/aws/eks/${var.cluster_name}/pods"
}


resource "aws_iam_role_policy_attachment" "workers_logs_access" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role = module.eks.worker_iam_role_name
}