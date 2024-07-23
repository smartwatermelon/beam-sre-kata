# modules/serverless/lambda/test_runner.rb

require 'json'
require_relative 'test_lambda'

def handler(event:, context:)
  test_result = TestLambda.run_tests

  puts JSON.generate(test_result)

  {
    statusCode: test_result[:success] ? 200 : 500,
    body: JSON.generate(test_result)
  }
end