resource "aws_ecr_repository" "repo" {
  #checkov:skip=CKV_AWS_51:We want to be able to reuse previous tags when rolling back changes

  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.kms_key.arn
  }
}

resource "aws_ecr_lifecycle_policy" "repo" {
  repository = aws_ecr_repository.repo.name

  # For unstable-<gitSHA> images, retain last 10 (by default)
  # For any stable (tagged with a vM.m.p value), retain last 5
  # Only retain one untagged image (ex: ad-hoc testing)
  # Keep anything else for manual cleanup (quarantine, etc)
  policy = <<-EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Retain only the last ${var.image_retention_unstable} unstable images",
              "selection": {
                  "tagStatus": "tagged",
                  "tagPrefixList": [
                    "unstable-"
                  ],
                  "countType": "imageCountMoreThan",
                  "countNumber": ${var.image_retention_unstable}
              },
              "action": {
                  "type": "expire"
              }
          },
          {
              "rulePriority": 2,
              "description": "Do not retain more than one untagged image",
              "selection": {
                  "tagStatus": "untagged",
                  "countType": "imageCountMoreThan",
                  "countNumber": 1
              },
              "action": {
                  "type": "expire"
              }
          },
          {
              "rulePriority": 3,
              "description": "Retain last 5 stable releases",
              "selection": {
                  "tagStatus": "tagged",
                  "tagPrefixList": [
                    "v"
                  ],
                  "countType": "imageCountMoreThan",
                  "countNumber": 5
              },
              "action": {
                  "type": "expire"
              }
          }
      ]
  }
  EOF
}
