# ./modules/serverless/lambda/test_runner.rb

require 'json'
require_relative 'test_lambda'

def handler(event:, context:)
  puts "Starting tests..."
  
  test_output = StringIO.new
  Minitest.reporter = Minitest::SummaryReporter.new(test_output)
  test_result = Minitest.run

  puts "Tests completed. Output:"
  puts test_output.string

  {
    statusCode: test_result ? 200 : 500,
    body: JSON.generate({
      success: test_result,
      message: test_result ? "All tests passed" : "Some tests failed",
      details: test_output.string
    })
  }
end