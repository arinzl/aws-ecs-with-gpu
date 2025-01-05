resource "aws_autoscaling_group" "ecs_hosts" {
  #checkov:skip=CKV_AWS_336: #TODO  https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-336
  #checkov:skip=CKV_AWS_315: #TODO  Launch template is being used, checkov unable to verify

  name = "${var.app_name}-ecs-hosts"

  max_size              = 1
  min_size              = 0
  desired_capacity      = var.asg_desired_capacity
  desired_capacity_type = "units"
  force_delete          = true
  vpc_zone_identifier   = data.aws_subnets.private.ids
  max_instance_lifetime = 60 * 60 * 24 * 7 * 2 # 2 weeks 

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1 #0 
      on_demand_percentage_above_base_capacity = 0
      on_demand_allocation_strategy            = "lowest-price"
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 0 #1
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs_host.id
        version            = "$Latest"
      }

      override {

        instance_requirements {
          memory_mib {
            min = 16384
            max = 32768
          }

          vcpu_count {
            min = 4
            max = 8
          }

          instance_generations = ["current"]

          accelerator_types         = ["gpu"]
          accelerator_manufacturers = ["nvidia"]
          allowed_instance_types    = ["g4*"]

          # gpu count
          accelerator_count {
            min = 1
            max = 4
          }
        }
      }

    }
  }

  instance_refresh {
    strategy = "Rolling"
  }


  tag {
    key                 = "Name"
    value               = "${var.app_name}-ECSHost"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "ecs_host" {
  name_prefix = "${var.app_name}-ecs-host-"
  image_id    = data.aws_ami.ecs_host.image_id

  instance_type = "g4dn.xlarge"

  user_data = base64encode(local.ecs_userdata)

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_host.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 30
      volume_type           = "gp3"
    }
  }

  vpc_security_group_ids = [aws_security_group.ecs_host.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

locals {
  ecs_userdata = <<-EOF
    #!/bin/bash

    cat <<'DOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${aws_ecs_cluster.main.name}
    ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
    ECS_LOG_DRIVER=awslogs
    ECS_LOG_OPTS={"awslogs-group":"/aws/ecs/${var.app_name}-ecs-cluster","awslogs-region":"${data.aws_region.current.name}"}
    ECS_LOGLEVEL=info
    DOF
  EOF
}

