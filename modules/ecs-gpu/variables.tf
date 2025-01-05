
variable "app_name" {
  description = "Name of application or project"
  type        = string
  default     = "ecs-gpu"
}

variable "image_retention_unstable" {
  description = "The number of unstable images to retain in the ECR repo"
  type        = number
  default     = 3
}

variable "cloudwatch_log_retention" {
  description = "Retention period for CloudWatch log groups in days"
  type        = number
  default     = 545
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the EC2 instances into"
  type        = string
}

# # #######ECS#######

variable "container_cpu" {
  description = "The number of cpu units used by the task"
  default     = 2048 #4096    
  type        = number
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 7500 #15731
  type        = number
}


variable "asg_desired_capacity" {
  description = "desired capacity of ASG used in footage export task group cluster"
  type        = number
}


# ## for testing only
variable "asset_bucket" {
  type        = string
  description = "source artifeat bucket"
  default     = "clip-enhancements"
}



