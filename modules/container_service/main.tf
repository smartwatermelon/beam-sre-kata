# ./modules/container_service/main.tf
# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  tags = var.tags
}

# Security group for the web application
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for the web application"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Security group for Redis
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ECS Task Definition for the web application
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "beamdental/sre-kata-app"
      portMappings = [
        {
          containerPort = 4567
          hostPort      = 4567
        }
      ]
      environment = [
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_static_ip}:6379"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])

  tags = var.tags
}

# CloudWatch Log Group for Redis
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/${var.project_name}-redis"
  retention_in_days = 7
  tags              = var.tags
}

# ECS Task Definition for Redis
resource "aws_ecs_task_definition" "redis" {
  family                   = "${var.project_name}-redis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "redis"
      image = var.redis_image
      portMappings = [
        {
          containerPort = var.redis_port
          hostPort      = var.redis_port
        }
      ]
    }
  ])

  tags = var.tags
}

# ECS Service for the web application
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }

  tags = var.tags
}

# ECS Service for Redis
resource "aws_ecs_service" "redis" {
  name            = "${var.project_name}-redis-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.redis.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [var.redis_subnet_id]
    security_groups  = [aws_security_group.redis.id]
    assign_public_ip = false
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-app"
  retention_in_days = 14
  tags              = var.tags
}