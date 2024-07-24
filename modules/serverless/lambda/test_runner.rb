# modules/serverless/lambda/test_runner.rb
require 'json'
require_relative 'test_lambda'

def handler(event:, context:)
  puts "Starting tests..."
  
  output = StringIO.new
  Minitest.reporter = Minitest::SummaryReporter.new(output)
  result = Minitest.run

  puts output.string
  
  message = result ? "All tests passed successfully" : "Some tests failed"
  puts message

  {
    statusCode: result ? 200 : 500,
    body: JSON.generate({
      success: result,
      message: message,
      details: output.string
    })
  }
end