# modules/serverless/main.tf

# Resource to create a ZIP file from our Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

# IAM role for Lambda execution
resource "aws_iam_role" "ar_lambda_role" {
  name = "AR-LambdaExecutionRole"

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

# IAM policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "ar_lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.ar_lambda_role.name
}

# Create a null resource to install gems and create a layer
resource "null_resource" "install_gems" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOF
      pushd ${path.module}/lambda_layer/ruby/gems
      bundle install --path .
      popd
      cd ${path.module}
      zip -r lambda_layer.zip lambda_layer
      echo "ZIP file creation complete"
    EOF
  }
}

# Lambda Layer resource
resource "aws_lambda_layer_version" "gems_layer" {
  filename            = "${path.module}/lambda_layer.zip"
  layer_name          = "ar-gems-layer"
  compatible_runtimes = ["ruby3.3"]

  depends_on = [null_resource.install_gems]
}

# Create a null resource to run the tests
resource "null_resource" "run_tests" {
  triggers = {
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda && ruby test_lambda.rb"
  }
}

# Test Runner Lambda function
resource "aws_lambda_function" "ar_test_runner" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AR-TestRunner"
  role             = aws_iam_role.ar_lambda_role.arn
  handler          = "test_runner.handler"
  runtime          = "ruby3.3"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [aws_lambda_layer_version.gems_layer.arn]

  tags = var.tags
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

/*
IAM user doesn't have necessary permissions

# EventBridge rule to run tests periodically
resource "aws_cloudwatch_event_rule" "test_schedule" {
  name                = "ar-run-tests-periodically"
  description         = "Runs Lambda function tests every day"
  schedule_expression = "rate(1 day)"
}

# Set Lambda function as target for the EventBridge rule
resource "aws_cloudwatch_event_target" "test_runner_target" {
  rule      = aws_cloudwatch_event_rule.test_schedule.name
  target_id = "AR-TestRunnerTarget"
  arn       = aws_lambda_function.ar_test_runner.arn
}

# Allow EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ar_test_runner.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.test_schedule.arn
}
*/

# Brewery Lambda function resource
resource "aws_lambda_function" "ar_brewery_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AR-BreweryParser"
  role             = aws_iam_role.ar_lambda_role.arn
  handler          = "index.handler"
  runtime          = "ruby3.3"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [aws_lambda_layer_version.gems_layer.arn]

  tags = var.tags
}

# CloudWatch Log Group for Lambda logs
resource "aws_cloudwatch_log_group" "ar_lambda_log_group" {
  name              = "/aws/lambda/AR-BreweryParser"
  retention_in_days = 14
  tags              = var.tags
}