resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app_name}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 4096
  memory                   = 15731
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-container"
      image     = "${aws_ecr_repository.repo.repository_url}:latest" #TO fix version to tag in each environment
      essential = true
      cpu       = var.container_cpu
      memory    = var.container_memory
      environment = [
        {
          name  = "TZ",
          value = "Pacific/Auckland"
        },
        {
          "name" : "ENVIRONMENT",
          "value" : terraform.workspace
        },
        {
          "name" : "AWS_REGION",
          "value" : data.aws_region.current.name
        },
        {
          "name" : "APPLICATION",
          "value" : var.app_name
        },
      ]

      logConfiguration = {
        "logDriver" = "awslogs"
        "options" = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_task.name,
          "awslogs-stream-prefix" = "ecs",
          "awslogs-region"        = data.aws_region.current.name
        }
      }
      mountPoints = [
      ]
      resourceRequirements = [
        {
          type  = "GPU",
          value = "1"
        }
      ]

    }
  ])

  tags = {
    Name = "${var.app_name}-task"
  }
}

