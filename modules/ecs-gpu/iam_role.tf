
#### ECS EC2 Host Role ####
resource "aws_iam_role" "ecs_host" {
  name               = "${var.app_name}-ecs-host"
  assume_role_policy = data.aws_iam_policy_document.ecs_host_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  #permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.devops-role-permission-boundary-name}"
}

data "aws_iam_policy_document" "ecs_host_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "ecs_host" {
  name = aws_iam_role.ecs_host.name
  role = aws_iam_role.ecs_host.id
}


#### ECS Common Task & TaskExecution Roles #####

data "aws_iam_policy_document" "ecs_assume_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#### ECS TaskExecution Role #####
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
  #permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.devops-role-permission-boundary-name}"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

#### ECS Task Role #####

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.app_name}-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
  #permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.devops-role-permission-boundary-name}"
}


resource "aws_iam_role_policy" "ecs_task" {
  name   = aws_iam_role.ecs_task_role.name
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task.json
}


data "aws_iam_policy_document" "ecs_task" {
  #checkov:skip=CKV_AWS_111:Unable to restrict logs access further
  #checkov:skip=CKV_AWS_356:skipping on wildcard '*' resource usage for iam policy, need to TODO later

  statement {
    sid = "taskcwlogging"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "encryptionOps"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.kms_key.arn,
    ]
  }

  statement {
    sid    = "s3Ops"
    effect = "Allow"
    actions = [
      "s3:PutObjectTagging",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
      "s3:ListAllMyBuckets"
    ]

    resources = ["*",
      # "arn:aws:s3:::${var.asset_bucket}-${terraform.workspace}",   #TODO remove after testing
      # "arn:aws:s3:::${var.asset_bucket}-${terraform.workspace}/*", #TODO remove after testing
      # "arn:aws:s3:::${var.output_footage_bucket}",
      # "arn:aws:s3:::${var.output_footage_bucket}/*"
    ]
  }

  # statement {
  #   sid    = "rekognitionAPIcalls"
  #   effect = "Allow"
  #   actions = [
  #     "rekognition:DetectText",
  #     "rekognition:ListTagsForResource",
  #   ]
  #   resources = ["*"]
  # }


}

