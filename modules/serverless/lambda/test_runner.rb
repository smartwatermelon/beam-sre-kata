# modules/serverless/lambda/test_runner.rb

resource "null_resource" "run_tests" {
  triggers = {
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda && ruby test_lambda.rb"
  }
}

# Lambda function resource
resource "aws_lambda_function" "ar_brewery_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AR-BreweryParser"
  role             = aws_iam_role.ar_lambda_role.arn
  handler          = "index.handler"
  runtime          = "ruby3.3"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  depends_on = [null_resource.run_tests]

  tags = var.tags
}
