resource "aws_cloudwatch_log_group" "ecs_cluster" {
  #checkov:skip=CKV_AWS_66:Retain logs indefinitely for troubleshooting
  #checkov:skip=CKV_AWS_338:Retain logs indefinitely for troubleshooting
  name = "/aws/ecs/${var.app_name}-ecs-cluster"

  kms_key_id        = aws_kms_key.kms_key.arn
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    Name = "${var.app_name}-ecs-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs_task" {
  #checkov:skip=CKV_AWS_66:Retain logs indefinitely for troubleshooting
  #checkov:skip=CKV_AWS_338:Retain logs indefinitely for troubleshooting
  name = "/aws/ecs/${var.app_name}-ecs-task"

  kms_key_id        = aws_kms_key.kms_key.arn
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    Name = "${var.app_name}-ecs-task"
  }
}


# resource "aws_cloudwatch_log_group" "ecs_cluster_perfomance" {
#   #checkov:skip=CKV_AWS_66:Retain logs indefinitely for troubleshooting
#   #checkov:skip=CKV_AWS_338:Retain logs indefinitely for troubleshooting
#   name              = "/aws/ecs/containerinsights/mpiobc-${var.name}/performance"
#   retention_in_days = var.cloudwatch_log_retention
#   kms_key_id        = aws_kms_key.kms_key.arn

# }
