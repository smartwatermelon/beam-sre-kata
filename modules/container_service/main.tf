# ./modules/container_service/main.tf

# Create ECR repository
resource "aws_ecr_repository" "app" {
  name = "${var.project_name}-app"
  tags = var.tags
}

# Build and push Docker image
resource "null_resource" "build_and_push_image" {
  triggers = {
    dockerfile_hash = filemd5("${path.root}/Dockerfile")
    script_hash     = filemd5("${path.root}/app_scripts/entrypoint.sh")
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}
      docker build -t ${var.project_name}-app ${path.root}
      docker tag ${var.project_name}-app:latest ${aws_ecr_repository.app.repository_url}:latest
      docker push ${aws_ecr_repository.app.repository_url}:latest
    EOF
  }

  depends_on = [aws_ecr_repository.app]
}

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
    from_port   = var.app_port
    to_port     = var.app_port
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
    from_port       = var.redis_port
    to_port         = var.redis_port
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

# ECS Task Definition for the web application and Redis
resource "aws_ecs_task_definition" "app_and_redis" {
  family                   = "${var.project_name}-app-and-redis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${aws_ecr_repository.app.repository_url}:latest"
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
      environment = [
        {
          name  = "ECS_CONTAINER_METADATA_URI_V4"
          value = "http://169.254.170.2/v4"
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
    },
    {
      name  = "redis"
      image = var.redis_image
      portMappings = [
        {
          containerPort = var.redis_port
          hostPort      = var.redis_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.redis.name
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])

  tags = var.tags

  depends_on = [null_resource.build_and_push_image]
}

# ECS Service for the web application and Redis
resource "aws_ecs_service" "app_and_redis" {
  name            = "${var.project_name}-app-and-redis-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_and_redis.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.app.id, aws_security_group.redis.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.app_port
  }

  tags = var.tags

  depends_on = [aws_lb_listener.app]
}

# Application Load Balancer
resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

  tags = var.tags
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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

# CloudWatch Log Group for App
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-app"
  retention_in_days = 14
  tags              = var.tags
}

# CloudWatch Log Group for Redis
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/${var.project_name}-redis"
  retention_in_days = 7
  tags              = var.tags
}