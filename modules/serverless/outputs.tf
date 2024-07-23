# modules/serverless/outputs.tf

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.ar_brewery_function.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.ar_brewery_function.arn
}