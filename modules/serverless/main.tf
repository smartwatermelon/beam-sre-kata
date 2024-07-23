# modules/serverless/main.tf

# Resource to create a ZIP file from our Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function resource
resource "aws_lambda_function" "ar_brewery_function" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "AR-BreweryParser"
  role          = aws_iam_role.ar_lambda_role.arn
  handler       = "index.handler"
  runtime       = "ruby2.7"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = var.tags
}

# CloudWatch Log Group for Lambda logs
resource "aws_cloudwatch_log_group" "ar_lambda_log_group" {
  name              = "/aws/lambda/AR-BreweryParser"
  retention_in_days = 14
  tags              = var.tags
}

# TODO: Add IAM role resource for Lambda execution
# TODO: Add IAM policy resources for Lambda execution and CloudWatch logging