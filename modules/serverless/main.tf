# ./modules/serverless/main.tf

# Generate a random suffix for resource names
resource "terraform_data" "random_suffix" {
  input = formatdate("YYYYMMDDhhmmss", timestamp())
}

# Install gems for Lambda function
resource "null_resource" "install_gems" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ${path.module}/lambda
      bundle config set path 'vendor/bundle'
      bundle install
      bundle lock --add-platform ruby
    EOF
  }
}

# Create a ZIP file from our Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
  depends_on  = [null_resource.install_gems]
}

# Run tests for Lambda function
resource "null_resource" "run_tests" {
  triggers = {
    lambda_code = data.archive_file.lambda_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda && ruby test_lambda.rb"
  }

  depends_on = [data.archive_file.lambda_zip]
}

# IAM role for Lambda execution
resource "aws_iam_role" "ar_lambda_role" {
  name = "AR-LambdaExecutionRole-${terraform_data.random_suffix.output}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "ar_lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.ar_lambda_role.name
}

# Lambda function for test runner
resource "aws_lambda_function" "ar_test_runner" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AR-TestRunner"
  role             = aws_iam_role.ar_lambda_role.arn
  handler          = "test_runner.handler"
  runtime          = "ruby3.3"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      BUNDLE_GEMFILE = "/var/task/Gemfile"
    }
  }

  tags = var.tags
  depends_on = [null_resource.run_tests]
}

# Lambda function for brewery parser
resource "aws_lambda_function" "ar_brewery_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AR-BreweryParser"
  role             = aws_iam_role.ar_lambda_role.arn
  handler          = "index.handler"
  runtime          = "ruby3.3"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUNDLE_GEMFILE = "/var/task/Gemfile"
    }
  }

  tags = var.tags
  depends_on = [null_resource.run_tests]
}

# CloudWatch Log Group for Lambda logs
resource "aws_cloudwatch_log_group" "ar_lambda_log_group" {
  name              = "/aws/lambda/AR-BreweryParser"
  retention_in_days = 14
  tags              = var.tags
}

# IAM policy for EventBridge permissions
resource "aws_iam_role_policy" "eventbridge_permissions" {
  name = "ar-eventbridge-permissions"
  role = aws_iam_role.ar_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "events:PutRule",
          "events:PutTargets",
          "events:DeleteRule",
          "events:RemoveTargets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}