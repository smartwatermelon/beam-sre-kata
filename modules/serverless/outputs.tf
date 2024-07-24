# ./modules/serverless/outputs.tf

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.ar_brewery_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.ar_brewery_function.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.ar_lambda_log_group.name
}