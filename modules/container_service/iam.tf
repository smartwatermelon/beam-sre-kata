# ./modules/container_service/iam.tf

resource "terraform_data" "random_suffix" {
  input = formatdate("YYYYMMDDhhmmss", timestamp())
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role_new" {
  name = "ar-sre-kata-ecs-exec-role-${terraform_data.random_suffix.output}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach the AmazonECSTaskExecutionRolePolicy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_new" {
  role       = aws_iam_role.ecs_task_execution_role_new.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_role_new" {
  name = "ar-sre-kata-ecs-task-role-${terraform_data.random_suffix.output}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Add permissions for ECS tasks to access the ECS Container Metadata
resource "aws_iam_role_policy" "ecs_task_metadata_policy_new" {
  name = "ar-sre-kata-ecs-metadata-policy-${terraform_data.random_suffix.output}"
  role = aws_iam_role.ecs_task_role_new.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      }
    ]
  })
}